from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
import spacy
from spacy.matcher import Matcher
from fractions import Fraction
import json


class IngredientParser:
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
        self.unit_map = {
            "tsp": "tsp", "teaspoon": "tsp", "teaspoons": "tsp",
            "tbsp": "tbsp", "tablespoon": "tbsp", "tablespoons": "tbsp",
            "cup": "cup", "cups": "cup",
            "gram": "gram", "grams": "gram", "g": "gram",
            "ounce": "ounce", "oz": "ounce", "ounces": "ounce",
            "pound": "pound", "lb": "pound", "lbs": "pound",
            "ml": "ml", "milliliter": "ml", "milliliters": "ml",
            "liter": "liter", "liters": "liter", "l": "liter",
            "pinch": "pinch", "pinches": "pinch",
            "dash": "dash", "dashes": "dash",
        }
        self.unit_conversion = {
            "teaspoon": 4.2, "tablespoon": 12.5, "cup": 200, "ounce": 28.35, "pound": 453.6, "gram": 1,
            "ml": 1, "liter": 1000, "pinch": 0.3, "dash": 0.6
        }

                # Define size modifiers list
        self.size_modifiers = ["small", "medium", "large", "extra large", "jumbo", "heaping", "scant"]

        # Add this new dictionary for standardized measurements
        self.measurement_dict = {
            "egg": {
                "small": 40,  # grams
                "medium": 45,
                "large": 50,
                "extra large": 60,
                "jumbo": 65,
                "default": 50
            },
            "onion": {
                "small": 110,
                "medium": 150,
                "large": 190,
                "default": 150
            },
            # More ingredients with size variations
        }
         # Special cases (eggs, to taste, pinch)
        self.special_cases = {
            "egg": 50,  # Avg weight of large egg
            "pinch of salt": 0.3,
            "to taste": "variable"
        }
        
        #  Mapping unit variations (singular/plural)
        self.unit_map = {u.rstrip("s"): u for u in self.unit_conversion.keys()}

        self.fraction_map = {
            "½": 0.5, "⅓": 0.33, "⅔": 0.66,
            "¼": 0.25, "¾": 0.75, "⅛": 0.125
        }
        self._create_patterns()

    def _create_patterns(self):
        """Create patterns for quantity and unit detection"""
        self.matcher = Matcher(self.nlp.vocab)
        
        # New pattern for combined numbers: [number] [fraction] [unit]
        self.matcher.add("COMBINED_NUMBER", [
            [{"LIKE_NUM": True}, {"TEXT": {"IN": list(self.fraction_map.keys())}}]
        ])
        self.matcher.add("NUMBER_INGREDIENT", [
            [{"LIKE_NUM": True}, {"POS": "ADJ", "OP": "?"}, {"POS": "NOUN"}]
        ])
        # Existing patterns
        self.matcher.add("FRACTION_UNIT", [
            [{"TEXT": {"IN": list(self.fraction_map.keys())}}, {"LOWER": {"IN": list(self.unit_map.keys())}}],
            [{"LIKE_NUM": True}, {"LOWER": {"IN": list(self.unit_map.keys())}}]
        ])

     # MODIFIED: Enhanced unit normalization to match converter
    def _normalize_unit(self, unit):
      unit = unit.lower().rstrip('s')  # Remove plurals first
      return self.unit_map.get(unit, unit)  # Use short form if exists

        # ================ MODIFIED: IngredientParser.parse() ================
    def parse(self, text):
      print(f"\n=== PARSING START: '{text}' ===")
      doc = self.nlp(text)
      matches = self.matcher(doc)
      
      quantity = 1.0
      unit = "unit"
      ingredient_tokens = []
      matched_span = None
      size_modifier = None
      notes = []
      
      # Prioritize UNIT matches first
      for match_id, start, end in matches:
          span = doc[start:end]
          match_type = self.nlp.vocab.strings[match_id]
          
          if match_type == "FRACTION_UNIT":
              if span[0].text in self.fraction_map:
                  quantity = self.fraction_map[span[0].text]
                  unit = self._normalize_unit(span[1].text)
              else:
                  try:
                      quantity = float(span[0].text)
                      unit = self._normalize_unit(span[1].text)
                  except ValueError:
                      continue
              matched_span = span
              break

      # If no unit found, look for standalone quantities
      if unit == "unit":
          for token in doc:
              if token.like_num:
                  try:
                      quantity = float(token.text)
                      # Look for unit in next token
                      if token.i+1 < len(doc) and doc[token.i+1].text in self.unit_map:
                          unit = self._normalize_unit(doc[token.i+1].text)
                          matched_span = doc[token.i:token.i+2]
                  except ValueError:
                      pass

      # Extract remaining tokens
      for token in doc:
          if not (matched_span and token in matched_span):
              text_lower = token.text.lower()
              if text_lower in self.size_modifiers:
                  size_modifier = text_lower
              elif text_lower in ["sifted", "packed"]:
                  notes.append(text_lower)
              else:
                  ingredient_tokens.append(token.text)

      # Clean ingredient name
      ingredient_name = " ".join(ingredient_tokens).strip()
      ingredient_name = re.sub(r'\s*-\s*', ' ', ingredient_name)  # Fix hyphen issue
      
      res= {
          "quantity": quantity,
          "unit": unit,
          "ingredient": ingredient_name,
          "notes": notes,
          "size_modifier": size_modifier,
          "text": text
      }
      print(f"DEBUG-PARSER: Raw parse -> Qty: {quantity}, Unit: '{unit}', Ingredient: '{ingredient_name}'")
      print(f"DEBUG-PARSER: Notes: {notes}, Size Modifier: {size_modifier}")

      return res

      
    def get_standardized_measurement(self, ingredient, size_modifier=None, quantity=1.0, unit="unit"):
      """Convert ingredient to standardized grams based on ingredient, size, quantity and unit"""
      # Handle common unit conversions
      if ingredient.lower() in self.measurement_dict:
          measures = self.measurement_dict[ingredient.lower()]
          
          # First check if we have a specific size+unit combo
          key = f"{size_modifier}_{unit}" if size_modifier else unit
          if key in measures:
              return measures[key] * quantity
          
          # Then check just size or just unit
          if size_modifier and size_modifier in measures:
              return measures[size_modifier] * quantity
          if unit in measures:
              return measures[unit] * quantity
          
          # Fall back to default
          if "default" in measures:
              return measures["default"] * quantity
class IngredientConverter:
    def __init__(self):
        # Conversion factors for common ingredients (approximate weight in grams per cup)
        self.conversion_table = {
            # Dry ingredients
            "flour": {
                "cup": {"default": 125, "sifted": 115, "packed": 130},      # All-purpose flour
                "tbsp": 7.5,
                "tsp": 2.5,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "sugar": {
                "cup": 200,      # Granulated sugar
                "tbsp": 12.5,
                "tsp": 4.2,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "brown sugar": {
                "cup": 220,      # Packed brown sugar
                "tbsp": 13.75,
                "tsp": 4.6,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "powdered sugar": {
                "cup": 125,     # Confectioners' sugar
                "tbsp": 7.8,
                "tsp": 2.6,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "cocoa powder": {
                "cup": 100,
                "tbsp": 6.25,
                "tsp": 2.1,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "salt": {
                "cup": 300,
                "tbsp": 18.75,
                "tsp": 6.25,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "baking powder": {
                "cup": 230,
                "tbsp": 14.4,
                "tsp": 4.8,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "baking soda": {
                "cup": 220,
                "tbsp": 13.75,
                "tsp": 4.6,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "cornstarch": {
                "cup": 120,
                "tbsp": 7.5,
                "tsp": 2.5,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            # Liquid ingredients
            "water": {
                "cup": 240,
                "tbsp": 15,
                "tsp": 5,
                "ml": 1,
                "liter": 1000,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6,
                "gallon": 3785,
                "quart": 946,
                "pint": 473
            },
            "milk": {
                "cup": 245,
                "tbsp": 15.3,
                "tsp": 5.1,
                "ml": 1.03,
                "liter": 1030,
                "gram": 1.03,
                "kg": 1030,
                "ounce": 29.2,
                "pound": 467.2,
                "lb": 467.2,
                "gallon": 3899,
                "quart": 975,
                "pint": 487
            },
            "oil": {
                "cup": 220,
                "tbsp": 13.75,
                "tsp": 4.6,
                "ml": 0.92,
                "liter": 920,
                "gram": 0.92,
                "kg": 920,
                "ounce": 26.1,
                "pound": 417.3,
                "lb": 417.3,
                "gallon": 3482,
                "quart": 871,
                "pint": 435
            },
            # Fats
            "butter": {
                "cup": 225,
                "stick": 113,  # 1 stick = 1/2 cup = 113g
                "tbsp": 14.2,
                "tsp": 4.7,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            # Common baking additions
            "chocolate chips": {
                "cup": 175,
                "tbsp": 10.9,
                "tsp": 3.6,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "nuts": {
                "cup": 150,  # varies by nut type and whether chopped
                "tbsp": 9.4,
                "tsp": 3.1,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "rolled oats": {
                "cup": 90,
                "tbsp": 5.6,
                "tsp": 1.9,
                "gram": 1,
                "kg": 1000,
                "ounce": 28.35,
                "pound": 453.6,
                "lb": 453.6
            },
            "egg": {  # Size-based weights
                "small": 40, "medium": 45, "large": 50, "default": 50
            },
        }

        # Standard volume unit conversions
        self.volume_conversions = {
            "teaspoon": "tsp",
            "tablespoon": "tbsp",
            "cup": "cup",
            "pint": "pint",
            "quart": "quart",
            "gallon": "gallon",
            "milliliter": "ml",
            "liter": "liter"
        }

        # Common aliases for ingredients
        self.ingredient_aliases = {
            "ap flour": "flour",
            "all-purpose flour": "flour",
            "all purpose flour": "flour",
            "granulated sugar": "sugar",
            "white sugar": "sugar",
            "caster sugar": "sugar",
            "confectioners sugar": "powdered sugar",
            "icing sugar": "powdered sugar",
            "unsalted butter": "butter",
            "salted butter": "butter",
            "vegetable oil": "oil",
            "canola oil": "oil",
            "olive oil": "oil",
            "semi-sweet chocolate chips": "chocolate chips",
            "semisweet chocolate chips": "chocolate chips",
            "milk chocolate chips": "chocolate chips",
            "walnuts": "nuts",
            "almonds": "nuts",
            "pecans": "nuts"
        }

    def standardize_unit(self, unit):
        """Convert various unit names to standard form."""
        unit = unit.lower().strip()

        # Handle plurals and abbreviations
        if unit in ['cups', 'cup']:
            return 'cup'
        elif unit in ['tbsp', 'tbs', 'tablespoon', 'tablespoons']:
            return 'tbsp'
        elif unit in ['tsp', 'teaspoon', 'teaspoons']:
            return 'tsp'
        elif unit in ['g', 'gram', 'grams']:
            return 'gram'
        elif unit in ['kg', 'kilogram', 'kilograms']:
            return 'kg'
        elif unit in ['oz', 'ounce', 'ounces']:
            return 'ounce'
        elif unit in ['lb', 'lbs', 'pound', 'pounds']:
            return 'lb'
        elif unit in ['ml', 'milliliter', 'milliliters']:
            return 'ml'
        elif unit in ['l', 'liter', 'liters']:
            return 'liter'
        elif unit in ['gallon', 'gallons']:
            return 'gallon'
        elif unit in ['quart', 'quarts']:
            return 'quart'
        elif unit in ['pint', 'pints']:
            return 'pint'
        elif unit in ['stick', 'sticks'] and 'butter' in self.ingredient_aliases:
            return 'stick'
        else:
            return unit  # Return as is if no match
    
    def identify_ingredient(self, ingredient_text):
        """Handle compound names like 'all-purpose flour'"""
        # Remove numbers and special characters
        clean_text = re.sub(r'[^a-zA-Z\s-]', '', ingredient_text).lower().strip()
       
        
        # Check multi-word matches first
        for key in self.conversion_table.keys():
            if key in clean_text:
                return key
        
        # Check aliases with word boundaries
        for alias, standard in self.ingredient_aliases.items():
            if re.search(r'\b' + re.escape(alias) + r'\b', clean_text):
                return standard
        
        # Try singular form
        singular = clean_text.rstrip('s')
        return singular if singular in self.conversion_table else None

    def convert_to_grams(self, parsed_ingredient):
        """Improved conversion with priority: size > notes > unit"""
        print(f"\n=== CONVERSION START ===")
        try:
            quantity = parsed_ingredient.get("quantity", 0)
            unit = self.standardize_unit(parsed_ingredient.get("unit", "unit"))
            ingredient_name = parsed_ingredient.get("ingredient", "")
            size_modifier = parsed_ingredient.get("size_modifier")
            notes = parsed_ingredient.get("notes", [])
            print(f"DEBUG-CONVERTER: Raw parse -> Qty: {quantity}, Unit: '{unit}', Ingredient: '{ingredient_name}'")
            print(f"DEBUG-CONVERTER: Input -> {parsed_ingredient}")


            # Clean ingredient name
            ingredient_name = re.sub(r'[^a-zA-Z\s]', '', ingredient_name).strip()
            print(f"DEBUG-CONVERTER: Cleaned name -> '{ingredient_name}'")
           
            
            
            # Identify ingredient with improved handling
            print("DEBUG-CONVERTER: Attempting ingredient identification...")
            identified = self.identify_ingredient(ingredient_name)
            print(f"DEBUG-CONVERTER: Identified as -> '{identified}'")

            print(f"[CONVERTER STAGE 2] Size modifier: {size_modifier}")
            print(f"[CONVERTER STAGE 3] Notes: {notes}")
            print(f"[CONVERTER STAGE 4] Identified ingredient: {identified}")
            if not identified:
                return {
                    "grams": None,
                    "message": f"Unknown ingredient: {ingredient_name}",
                    "original": parsed_ingredient
                }

            # Handle size-based ingredients first (e.g. eggs)
            if size_modifier:
                print(f"[CONVERTER SIZE HANDLING] Using size '{size_modifier}'")
                size_data = self.conversion_table.get(identified, {})
                if isinstance(size_data, dict) and size_modifier in size_data:
                    grams = quantity * size_data[size_modifier]
                    return {
                        "grams": round(grams, 1),
                        "message": f"Converted {quantity} {size_modifier} {identified}",
                        "original": parsed_ingredient
                    }

            # Handle note-based conversions (e.g. packed brown sugar)
            conversion_data = self.conversion_table.get(identified, {})
            unit_data = conversion_data.get(unit, {})
            
            if isinstance(unit_data, dict):
                # Use first applicable note or default
                selected_note = next((n for n in notes if n in unit_data), "default")
                grams_per = unit_data.get(selected_note, 0)
            else:
                grams_per = unit_data

            if grams_per == 0:
                return {
                    "grams": None,
                    "message": f"No conversion for {unit} of {identified}",
                    "original": parsed_ingredient
                }

            grams = quantity * grams_per
            return {
                "grams": round(grams, 1),
                "message": f"Converted {quantity} {unit} {identified}",
                "original": parsed_ingredient
            }
            print(f"[CONVERTER CALCULATION] {quantity} {unit} * {grams_per} = {grams}g")

        except Exception as e:
            return {
                "grams": None,
                "message": f"Conversion error: {str(e)}",
                "original": parsed_ingredient
            }



# ✅ Fix the class initialization issue
class BakingRecipeScraper:
    def __init__(self, url: str):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops
        self.ingredient_parser = IngredientParser()
        self.converter = IngredientConverter()
    
    def fetch_page(self):
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(self.url, headers=headers)
        response.encoding = 'utf-8'
        if response.status_code == 200:
            self.soup = BeautifulSoup(response.text, "html.parser")
        else:
            raise Exception("Failed to fetch page")

    def extract_title(self):
        title_tag = self.soup.find("h1") or self.soup.find("title")
        return title_tag.text.strip() if title_tag else "No title found"

    
    def extract_ingredients(self):  
        ingredients = set()

        # Approach 1: Find ingredient lists based on headings (e.g., "Ingredients")
        headings = self.soup.find_all(['h1','h2', 'h3', 'h4','h5','h6'], text=lambda t: t and "ingredient" in t.lower())
        for heading in headings:
            # Look for the next sibling that is a list (<ul> or <ol>)
            next_sibling = heading.find_next_sibling()
            if next_sibling and next_sibling.name in ['ul', 'ol']:
                for li in next_sibling.find_all('li'):
                    text = li.get_text(separator=" ", strip=True)
                    if text:
                        ingredients.add(text)

        # Approach 2: Directly search for elements with class containing "ingredient"
        ingredient_tags = self.soup.find_all(["li", "span", "p",'ol'], 
                                            class_=lambda x: x and "ingredient" in x.lower())
        for tag in ingredient_tags:
            text = tag.get_text(separator=" ", strip=True)
            if text:
                ingredients.add(text)

        # Approach 3: Fallback heuristic—look for list items containing common measurement units
        if not ingredients:
            li_tags = self.soup.find_all("li")
            for li in li_tags:
                text = li.get_text(separator=" ", strip=True)
                # Match common measurement units (you can expand this list as needed)
                if re.search(r'\b(cup|cups|tsp|teaspoon|tbsp|tablespoon|gram|g|ounce|oz|pound|lb|ml|liter|l|pinch|dash)\b',
                            text, re.IGNORECASE):
                    ingredients.add(text)

        return list(ingredients) if ingredients else ["Ingredients not found"]


    def parse_ingredient(self, text):
        
        print(f"\n{'='*30}\n[SCRAPER] Processing: '{text}'")
      # Use the ingredient parser to get quantity/unit/ingredient
        parsed_result = self.ingredient_parser.parse(text)  # <-- This returns a dict
        
        
        parsed_result["text"] = text
        
        # NEW: Perform conversion to grams
        conversion_result = self.converter.convert_to_grams(parsed_result)
        parsed_result.update(conversion_result)
        print(f"[SCRAPER FINAL] Before: {parsed_result}\nAfter conversion: {conversion_result}")
        return parsed_result
                
    
    def regex_parse_ingredient(self, text):
        """Parse ingredient text using regex method (original implementation)."""
        # Regex pattern to capture quantity, unit, and ingredient
        pattern = r"""
            ^\s*                                      # Start of string
            (?P<quantity>                             # Quantity (e.g., 1/2, 0.75, 12, 1 1/2)
                \d+\s*/\s*\d+|                        # Fractions like 1/2
                \d+\.?\d*|                            # Decimals or integers
                \d+\s+\d+\s*/\s*\d+                   # Mixed numbers like "1 1/2"
            )\s*
            (?P<unit>                                 # Units (e.g., cup, g)
                tsp|tbsp|teaspoons?|tablespoons?|  # Explicit plurals
                cups?|grams?|g|kg|ml|oz|lbs?|      
                pinch(es)?|dash(es)?|pound|lb|     
                quarts?|pints?|gallons?|liters?|bunch|bottle|can|container|package
            )?\s*                                     # Unit is optional
            (?P<ingredient>                           # Ingredient name and notes
                .*?                                   # Non-greedy match
            )
            \s*$                                      # End of string
        """.strip()

        match = re.match(pattern, text, re.IGNORECASE | re.VERBOSE)
        if not match:
            return {"text": text, "error": "Could not parse"}

        # Extract groups
        quantity_str = match.group("quantity").strip()
        unit = (match.group("unit") or "unit").lower().rstrip('s')  # Singularize unit
        ingredient = match.group("ingredient").strip()

        # Convert quantity to float
        try:
            if '/' in quantity_str:  # Handle fractions (e.g., "1/2")
                quantity = float(Fraction(quantity_str))
            elif ' ' in quantity_str:  # Handle mixed numbers (e.g., "1 1/2")
                whole, fraction = quantity_str.split(' ')
                quantity = float(whole) + float(Fraction(fraction))
            else:  # Handle whole numbers (e.g., "12")
                quantity = float(quantity_str)
        except:
            return {"text": text, "error": "Invalid quantity"}

        # Clean ingredient name (remove symbols like *)
        ingredient = re.sub(r"[^\w\s-]", "", ingredient).strip()

        return {
            "quantity": quantity,
            "unit": unit,
            "ingredient": ingredient
        }

    def extract_instructions(self):
        instructions = []
        step_tags = self.soup.find_all(["li", "p"], class_=lambda x: x and "instruction" in x.lower())
        if step_tags:
            for tag in step_tags:
                instructions.append(tag.text.strip())
        return instructions if instructions else ["Instructions not found"]

    def is_baking_recipe(self, ingredients, instructions):
        baking_keywords = ["bake", "oven", "flour", "sugar", "butter", "yeast"]
        combined_text = " ".join(ingredients + instructions).lower()
        return any(keyword in combined_text for keyword in baking_keywords)

    def find_next_page(self):
        next_link = self.soup.find("a", string=re.compile(r"next|more|→", re.IGNORECASE))
        if next_link and next_link.get("href"):
            next_url = next_link["href"]
            return next_url if next_url.startswith("http") else f"{self.base_url}{next_url}"
        return None
    
    def save_to_json(self, data, filename="scraped_recipe.json"):
        try:
            # Read existing data if the file exists
            try:
                with open(filename, 'r') as f:
                    existing_data = json.load(f)
            except (FileNotFoundError, json.JSONDecodeError):
                existing_data = []

            # Append new data
            existing_data.append(data)

            # Write data back to the file
            with open(filename, 'w') as f:
                json.dump(existing_data, f, indent=4)
            print(f"Data saved to {filename}")
        except Exception as e:
            print(f"Error saving data to JSON: {e}")

    
    def scrape_recipe(self):
        self.fetch_page()
        title = self.extract_title()
        raw_ingredients = self.extract_ingredients()
        instructions = self.extract_instructions()

        # Parse each ingredient
        parsed_ingredients = []
        for ingredient_text in raw_ingredients:
            parsed = self.parse_ingredient(ingredient_text)
            parsed_ingredients.append(parsed)

        if self.is_baking_recipe(raw_ingredients, instructions):
            result = {
                "title": title,
                "ingredients": parsed_ingredients,
                "instructions": instructions,
                "url": self.url
            }
            self.save_to_json(result)

            return result

        else:
            return {"error": "Not a baking recipe."}
        
