
# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel
# from pydantic import AnyUrl
# from typing import Dict, List, Tuple, Optional, Union
# import requests
# from bs4 import BeautifulSoup
# import re
# import spacy
# from spacy.matcher import Matcher
# from fractions import Fraction
# import json
# from dataclasses import dataclass
# from spacy.training import Example

# app = FastAPI()
# class IngredientResult(BaseModel):
#     quantity: float
#     unit: str
#     ingredient: str
#     modifiers: List[str]
#     original: str
#     grams: Optional[float] = None
#     # Character spans for NER training
#     quantity_span: Optional[Tuple[int, int]] = None
#     unit_span: Optional[Tuple[int, int]] = None
#     ingredient_span: Optional[Tuple[int, int]] = None
#     modifier_spans: List[Tuple[int, int]] = None

# class RecipeResult(BaseModel):
#     title: str
#     ingredients: list[IngredientResult]
#     instructions: list[str]
#     url: str



# class IngredientParser:
#     def __init__(self):
#         self.nlp = spacy.load("en_core_web_sm")

#         self.unit_map = {
#             "tsp": "tsp", "teaspoon": "tsp", "teaspoons": "tsp",
#             "tbsp": "tbsp", "tablespoon": "tbsp", "tablespoons": "tbsp",
#             "cup": "cup", "cups": "cup",
#             "c": "cup",
#             "g": "gram", "grams": "gram",
#             "gram": "gram", "g": "gram",
#             "ounce": "ounce", "oz": "ounce", "ounces": "ounce",
#             "pound": "pound", "lb": "pound", "lbs": "pound",
#             "ml": "ml", "milliliter": "ml", "milliliters": "ml",
#             "liter": "liter", "liters": "liter", "l": "liter",
#             "pinch": "pinch", "pinches": "pinch",
#             "dash": "dash", "dashes": "dash",
#         }
#         self.unit_conversion = {
#             'g': 1.0, 'gram': 1.0, 'grams': 1.0, 'gr': 1.0,
#             'kg': 1000.0, 'kilogram': 1000.0, 'kilograms': 1000.0,
#             'oz': 28.35, 'ounce': 28.35, 'ounces': 28.35,
#             'lb': 453.59, 'pound': 453.59, 'pounds': 453.59, 'lbs': 453.59,
#               # Volume units (approximate conversions for common ingredients)
#             'ml': 1.0, 'milliliter': 1.0, 'milliliters': 1.0, 'millilitre': 1.0, 'millilitres': 1.0,
#             'l': 1000.0, 'liter': 1000.0, 'liters': 1000.0, 'litre': 1000.0, 'litres': 1000.0,
#             'cup': 240.0, 'cups': 240.0, 'c': 240.0,
#             'tablespoon': 15.0, 'tablespoons': 15.0, 'tbsp': 15.0, 'tbs': 15.0,
#             'teaspoon': 5.0, 'teaspoons': 5.0, 'tsp': 5.0,
#             'fl oz': 30.0, 'fluid ounce': 30.0, 'fluid ounces': 30.0, 'floz': 30.0,
#             'pint': 473.0, 'pints': 473.0, 'pt': 473.0,
#             'quart': 946.0, 'quarts': 946.0, 'qt': 946.0,
#             'gallon': 3785.0, 'gallons': 3785.0, 'gal': 3785.0,
             
#             # Special cases
#             'pinch': 0.3, 'pinches': 0.3,
#             'dash': 0.6, 'dashes': 0.6,
#             'handful': 40.0, 'handfuls': 40.0,
#         }

#                 # Define size modifiers list
#         self.size_modifiers = ["small", "medium", "large", "extra large", "jumbo", "heaping", "scant"]

#         # Add this new dictionary for standardized measurements
#         self.measurement_dict = {
#             "egg": {
#                 "small": 40,  # grams
#                 "medium": 45,
#                 "large": 50,
#                 "extra large": 60,
#                 "jumbo": 65,
#                 "default": 50
#             },
#             "onion": {
#                 "small": 110,
#                 "medium": 150,
#                 "large": 190,
#                 "default": 150
#             },
#             # More ingredients with size variations
#         }
#          # Special cases (eggs, to taste, pinch)
#         self.special_cases = {
#             "egg": 50,  # Avg weight of large egg
#             "pinch of salt": 0.3,
#             "to taste": "variable"
#         }
        
#         #  Mapping unit variations (singular/plural)
#         #self.unit_map = {u.rstrip("s"): u for u in self.unit_conversion.keys()}

#         self.fraction_map = {
#             '¼': 0.25, '½': 0.5, '¾': 0.75,
#             '⅐': 1/7, '⅑': 1/9, '⅒': 0.1,
#             '⅓': 1/3, '⅔': 2/3, '⅕': 0.2,
#             '⅖': 0.4, '⅗': 0.6, '⅘': 0.8,
#             '⅙': 1/6, '⅚': 5/6, '⅛': 0.125,
#             '⅜': 0.375, '⅝': 0.625, '⅞': 0.875
#         }
#         # Quantity word mappings
#         self.quantity_words = {
#             'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
#             'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
#             'dozen': 12, 'half': 0.5, 'quarter': 0.25
#         }
#         self._create_patterns()

#     def _create_patterns(self):
#         """Create patterns for quantity and unit detection"""
#         self.matcher = Matcher(self.nlp.vocab)
        
#         # New pattern for combined numbers: [number] [fraction] [unit]
#         self.matcher.add("COMBINED_NUMBER", [
#             [{"LIKE_NUM": True}, {"TEXT": {"IN": list(self.fraction_map.keys())}}]
#         ])
#         self.matcher.add("NUMBER_INGREDIENT", [
#             [{"LIKE_NUM": True}, {"POS": "ADJ", "OP": "?"}, {"POS": "NOUN"}]
#         ])
#         # Existing patterns
#         self.matcher.add("FRACTION_UNIT", [
#             [{"TEXT": {"IN": list(self.fraction_map.keys())}}, {"LOWER": {"IN": list(self.unit_map.keys())}}],
#             [{"LIKE_NUM": True}, {"LOWER": {"IN": list(self.unit_map.keys())}}]
#         ])

#      # MODIFIED: Enhanced unit normalization to match converter
#     def _normalize_unit(self, unit):
#       unit = unit.lower().rstrip('s')  # Remove plurals first
#       return self.unit_map.get(unit, unit)  # Use short form if exists

#         # ================ MODIFIED: IngredientParser.parse() ================
#     def parse(self, text):
#       print(f"\n=== PARSING START: '{text}' ===")
#       doc = self.nlp(text)
#       matches = self.matcher(doc)
      
#       quantity = 1.0
#       unit = "unit"
#       ingredient_tokens = []
#       matched_span = None
#       size_modifier = None
#       notes = []
      
#       # Prioritize UNIT matches first
#       for match_id, start, end in matches:
#           span = doc[start:end]
#           match_type = self.nlp.vocab.strings[match_id]
          
#           if match_type == "FRACTION_UNIT":
#               if span[0].text in self.fraction_map:
#                   quantity = self.fraction_map[span[0].text]
#                   unit = self._normalize_unit(span[1].text)
#               else:
#                   try:
#                       quantity = float(span[0].text)
#                       unit = self._normalize_unit(span[1].text)
#                   except ValueError:
#                       continue
#               matched_span = span
#               break

#       # If no unit found, look for standalone quantities
#       if unit == "unit":
#           for token in doc:
#               if token.like_num:
#                   try:
#                       quantity = float(token.text)
#                       # Look for unit in next token
#                       if token.i+1 < len(doc) and doc[token.i+1].text in self.unit_map:
#                           unit = self._normalize_unit(doc[token.i+1].text)
#                           matched_span = doc[token.i:token.i+2]
#                   except ValueError:
#                       pass
#       if unit == "unit":
#         for token in doc:
#             if token.text.lower() in self.unit_map:
#                 unit = self._normalize_unit(token.text)
#                 # Look for quantity in previous token if not already set
#                 if token.i > 0 and doc[token.i-1].like_num:
#                     quantity = float(doc[token.i-1].text)
#                 break

#       # Extract remaining tokens
#       for token in doc:
#           if not (matched_span and token in matched_span):
#               text_lower = token.text.lower()
#               if text_lower in self.size_modifiers:
#                   size_modifier = text_lower
#               elif text_lower in ["sifted", "packed"]:
#                   notes.append(text_lower)
#               else:
#                   ingredient_tokens.append(token.text)

#       # Clean ingredient name
#       ingredient_name = " ".join(ingredient_tokens).strip()
#       ingredient_name = re.sub(r'\s*-\s*', ' ', ingredient_name)  # Fix hyphen issue
      
#       res= {
#           "quantity": quantity,
#           "unit": unit,
#           "ingredient": ingredient_name,
#           "notes": notes,
#           "size_modifier": size_modifier,
#           "text": text
#       }
#       print(f"DEBUG-PARSER: Raw parse -> Qty: {quantity}, Unit: '{unit}', Ingredient: '{ingredient_name}'")
#       print(f"DEBUG-PARSER: Notes: {notes}, Size Modifier: {size_modifier}")

#       return res

      
#     def get_standardized_measurement(self, ingredient, size_modifier=None, quantity=1.0, unit="unit"):
#       """Convert ingredient to standardized grams based on ingredient, size, quantity and unit"""
#       # Handle common unit conversions
#       if ingredient.lower() in self.measurement_dict:
#           measures = self.measurement_dict[ingredient.lower()]
          
#           # First check if we have a specific size+unit combo
#           key = f"{size_modifier}_{unit}" if size_modifier else unit
#           if key in measures:
#               return measures[key] * quantity
          
#           # Then check just size or just unit
#           if size_modifier and size_modifier in measures:
#               return measures[size_modifier] * quantity
#           if unit in measures:
#               return measures[unit] * quantity
          
#           # Fall back to default
#           if "default" in measures:
#               return measures["default"] * quantity
# class IngredientConverter:
#     def __init__(self):
#         # Conversion factors for common ingredients (approximate weight in grams per cup)
#         self.conversion_table = {
#             # Dry ingredients
#             "flour": {
#                 "cup": {"default": 125, "sifted": 115, "packed": 130},      # All-purpose flour
#                 "tbsp": 7.5,
#                 "tsp": 2.5,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "sugar": {
#                 "cup": 200,      # Granulated sugar
#                 "tbsp": 12.5,
#                 "tsp": 4.2,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "brown sugar": {
#                 "cup": 220,      # Packed brown sugar
#                 "tbsp": 13.75,
#                 "tsp": 4.6,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "powdered sugar": {
#                 "cup": 125,     # Confectioners' sugar
#                 "tbsp": 7.8,
#                 "tsp": 2.6,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "cocoa powder": {
#                 "cup": 100,
#                 "tbsp": 6.25,
#                 "tsp": 2.1,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "salt": {
#                 "cup": 300,
#                 "tbsp": 18.75,
#                 "tsp": 6.25,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "baking powder": {
#                 "cup": 230,
#                 "tbsp": 14.4,
#                 "tsp": 4.8,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "baking soda": {
#                 "cup": 220,
#                 "tbsp": 13.75,
#                 "tsp": 4.6,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "cornstarch": {
#                 "cup": 120,
#                 "tbsp": 7.5,
#                 "tsp": 2.5,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             # Liquid ingredients
#             "water": {
#                 "cup": 240,
#                 "tbsp": 15,
#                 "tsp": 5,
#                 "ml": 1,
#                 "liter": 1000,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6,
#                 "gallon": 3785,
#                 "quart": 946,
#                 "pint": 473
#             },
#             "milk": {
#                 "cup": 245,
#                 "tbsp": 15.3,
#                 "tsp": 5.1,
#                 "ml": 1.03,
#                 "liter": 1030,
#                 "gram": 1.03,
#                 "kg": 1030,
#                 "ounce": 29.2,
#                 "pound": 467.2,
#                 "lb": 467.2,
#                 "gallon": 3899,
#                 "quart": 975,
#                 "pint": 487
#             },
#             "oil": {
#                 "cup": 220,
#                 "tbsp": 13.75,
#                 "tsp": 4.6,
#                 "ml": 0.92,
#                 "liter": 920,
#                 "gram": 0.92,
#                 "kg": 920,
#                 "ounce": 26.1,
#                 "pound": 417.3,
#                 "lb": 417.3,
#                 "gallon": 3482,
#                 "quart": 871,
#                 "pint": 435
#             },
#             # Fats
#             "butter": {
#                 "cup": 225,
#                 "stick": 113,  # 1 stick = 1/2 cup = 113g
#                 "tbsp": 14.2,
#                 "tsp": 4.7,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             # Common baking additions
#             "chocolate chips": {
#                 "cup": 175,
#                 "tbsp": 10.9,
#                 "tsp": 3.6,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "nuts": {
#                 "cup": 150,  # varies by nut type and whether chopped
#                 "tbsp": 9.4,
#                 "tsp": 3.1,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "rolled oats": {
#                 "cup": 90,
#                 "tbsp": 5.6,
#                 "tsp": 1.9,
#                 "gram": 1,
#                 "kg": 1000,
#                 "ounce": 28.35,
#                 "pound": 453.6,
#                 "lb": 453.6
#             },
#             "egg": {  # Size-based weights
#                 "small": 40, "medium": 45, "large": 50, "default": 50
#             },
#         }

#         # Standard volume unit conversions
#         self.volume_conversions = {
#             "teaspoon": "tsp",
#             "tablespoon": "tbsp",
#             "cup": "cup",
#             "pint": "pint",
#             "quart": "quart",
#             "gallon": "gallon",
#             "milliliter": "ml",
#             "liter": "liter"
#         }

#         # Common aliases for ingredients
#         self.ingredient_aliases = {
#             "ap flour": "flour",
#             "all-purpose flour": "flour",
#             "all purpose flour": "flour",
#             "granulated sugar": "sugar",
#             "white sugar": "sugar",
#             "caster sugar": "sugar",
#             "confectioners sugar": "powdered sugar",
#             "icing sugar": "powdered sugar",
#             "unsalted butter": "butter",
#             "salted butter": "butter",
#             "vegetable oil": "oil",
#             "canola oil": "oil",
#             "olive oil": "oil",
#             "semi-sweet chocolate chips": "chocolate chips",
#             "semisweet chocolate chips": "chocolate chips",
#             "milk chocolate chips": "chocolate chips",
#             "walnuts": "nuts",
#             "almonds": "nuts",
#             "pecans": "nuts"
#         }

#     def standardize_unit(self, unit):
#         """Convert various unit names to standard form."""
#         unit = unit.lower().strip()

#         # Handle plurals and abbreviations
#         if unit in ['cups', 'cup']:
#             return 'cup'
#         elif unit in ['tbsp', 'tbs', 'tablespoon', 'tablespoons']:
#             return 'tbsp'
#         elif unit in ['tsp', 'teaspoon', 'teaspoons']:
#             return 'tsp'
#         elif unit in ['g', 'gram', 'grams']:
#             return 'gram'
#         elif unit in ['kg', 'kilogram', 'kilograms']:
#             return 'kg'
#         elif unit in ['oz', 'ounce', 'ounces']:
#             return 'ounce'
#         elif unit in ['lb', 'lbs', 'pound', 'pounds']:
#             return 'lb'
#         elif unit in ['ml', 'milliliter', 'milliliters']:
#             return 'ml'
#         elif unit in ['l', 'liter', 'liters']:
#             return 'liter'
#         elif unit in ['gallon', 'gallons']:
#             return 'gallon'
#         elif unit in ['quart', 'quarts']:
#             return 'quart'
#         elif unit in ['pint', 'pints']:
#             return 'pint'
#         elif unit in ['stick', 'sticks'] and 'butter' in self.ingredient_aliases:
#             return 'stick'
#         else:
#             return unit  # Return as is if no match
    
#     def identify_ingredient(self, ingredient_text):
#         """Handle compound names like 'all-purpose flour'"""
#         # Remove numbers and special characters
#         clean_text = re.sub(r'[^a-zA-Z\s-]', '', ingredient_text).lower().strip()
       
        
#         # Check multi-word matches first
#         for key in self.conversion_table.keys():
#             if key in clean_text:
#                 return key
        
#         # Check aliases with word boundaries
#         for alias, standard in self.ingredient_aliases.items():
#             if re.search(r'\b' + re.escape(alias) + r'\b', clean_text):
#                 return standard
        
#         # Try singular form
#         singular = clean_text.rstrip('s')
#         return singular if singular in self.conversion_table else None

#     def convert_to_grams(self, parsed_ingredient):
#         """Improved conversion with priority: size > notes > unit"""
#         print(f"\n=== CONVERSION START ===")
#         try:
#             quantity = parsed_ingredient.get("quantity", 0)
#             unit = self.standardize_unit(parsed_ingredient.get("unit", "unit"))
#             ingredient_name = parsed_ingredient.get("ingredient", "")
#             size_modifier = parsed_ingredient.get("size_modifier")
#             notes = parsed_ingredient.get("notes", [])
#             print(f"DEBUG-CONVERTER: Raw parse -> Qty: {quantity}, Unit: '{unit}', Ingredient: '{ingredient_name}'")
#             print(f"DEBUG-CONVERTER: Input -> {parsed_ingredient}")


#             # Clean ingredient name
#             ingredient_name = re.sub(r'[^a-zA-Z\s]', '', ingredient_name).strip()
#             print(f"DEBUG-CONVERTER: Cleaned name -> '{ingredient_name}'")
           
            
            
#             # Identify ingredient with improved handling
#             print("DEBUG-CONVERTER: Attempting ingredient identification...")
#             identified = self.identify_ingredient(ingredient_name)
#             print(f"DEBUG-CONVERTER: Identified as -> '{identified}'")

#             print(f"[CONVERTER STAGE 2] Size modifier: {size_modifier}")
#             print(f"[CONVERTER STAGE 3] Notes: {notes}")
#             print(f"[CONVERTER STAGE 4] Identified ingredient: {identified}")
#             if not identified:
#                 return {
#                     "grams": None,
#                     "message": f"Unknown ingredient: {ingredient_name}",
#                     "original_text": parsed_ingredient.get("text")
#                 }

#             # Handle size-based ingredients first (e.g. eggs)
#             if size_modifier:
#                 print(f"[CONVERTER SIZE HANDLING] Using size '{size_modifier}'")
#                 size_data = self.conversion_table.get(identified, {})
#                 if isinstance(size_data, dict) and size_modifier in size_data:
#                     grams = quantity * size_data[size_modifier]
#                     return {
#                         "grams": round(grams, 1),
#                         "message": f"Converted {quantity} {size_modifier} {identified}",
#                         "original_text": parsed_ingredient.get("text")
#                     }

#             # Handle note-based conversions (e.g. packed brown sugar)
#             conversion_data = self.conversion_table.get(identified, {})
#             unit_data = conversion_data.get(unit, {})
            
#             if isinstance(unit_data, dict):
#                 # Use first applicable note or default
#                 selected_note = next((n for n in notes if n in unit_data), "default")
#                 grams_per = unit_data.get(selected_note, 0)
#             else:
#                 grams_per = unit_data

#             if grams_per == 0:
#                 return {
#                     "grams": None,
#                     "message": f"No conversion for {unit} of {identified}",
#                     "original_text": parsed_ingredient.get("text")
#                 }

#             grams = quantity * grams_per
#             print(f"[CONVERTER CALCULATION] {quantity} {unit} * {grams_per} = {grams}g")
#             return {
#                 "grams": round(grams, 1),
#                 "message": f"Converted {quantity} {unit} {identified}",
               
#             }
            

#         except Exception as e:
#             return {
#                 "grams": None,
#                 "message": f"Conversion error: {str(e)}",
#                 "original": parsed_ingredient
#             }



# # ✅ Define a request model
# class ScrapeRequest(BaseModel):
#     url: str


# # ✅ Fix the class initialization issue
# class BakingRecipeScraper:
#     def __init__(self, url: str):
#         self.url = url
#         self.soup = None
#         self.base_url = "/".join(url.split("/")[:3])
#         self.max_pages = 3  # Prevent infinite loops
#         self.ingredient_parser = IngredientParser()
#         self.converter = IngredientConverter()
    
#     def fetch_page(self):
#         headers = {"User-Agent": "Mozilla/5.0"}
#         response = requests.get(self.url, headers=headers)
#         response.encoding = 'utf-8'
#         if response.status_code == 200:
#             self.soup = BeautifulSoup(response.text, "html.parser")
#         else:
#             raise Exception("Failed to fetch page")

#     def extract_title(self):
#         title_tag = self.soup.find("h1") or self.soup.find("title")
#         return title_tag.text.strip() if title_tag else "No title found"

    
#     def extract_ingredients(self):  
#         ingredients = set()

#         # Approach 1: Find ingredient lists based on headings (e.g., "Ingredients")
#         headings = self.soup.find_all(['h1','h2', 'h3', 'h4','h5','h6'], text=lambda t: t and "ingredient" in t.lower())
#         for heading in headings:
#             # Look for the next sibling that is a list (<ul> or <ol>)
#             next_sibling = heading.find_next_sibling()
#             if next_sibling and next_sibling.name in ['ul', 'ol']:
#                 for li in next_sibling.find_all('li'):
#                     text = li.get_text(separator=" ", strip=True)
#                     if text:
#                         ingredients.add(text)

#         # Approach 2: Directly search for elements with class containing "ingredient"
#         ingredient_tags = self.soup.find_all(["li", "span", "p",'ol'], 
#                                             class_=lambda x: x and "ingredient" in x.lower())
#         for tag in ingredient_tags:
#             text = tag.get_text(separator=" ", strip=True)
#             if text:
#                 ingredients.add(text)

#         # Approach 3: Fallback heuristic—look for list items containing common measurement units
#         if not ingredients:
#             li_tags = self.soup.find_all("li")
#             for li in li_tags:
#                 text = li.get_text(separator=" ", strip=True)
#                 # Match common measurement units (you can expand this list as needed)
#                 if re.search(r'\b(cup|cups|tsp|teaspoon|tbsp|tablespoon|gram|g|ounce|oz|pound|lb|ml|liter|l|pinch|dash)\b',
#                             text, re.IGNORECASE):
#                     ingredients.add(text)

#         return list(ingredients) if ingredients else ["Ingredients not found"]


#     def parse_ingredient(self, text):
        
#         print(f"\n{'='*30}\n[SCRAPER] Processing: '{text}'")
#       # Use the ingredient parser to get quantity/unit/ingredient
#         parsed_result = self.ingredient_parser.parse(text)  # <-- This returns a dict
        
        
#         parsed_result["text"] = text
        
#         # NEW: Perform conversion to grams
#         conversion_result = self.converter.convert_to_grams(parsed_result)
#         parsed_result.update(conversion_result)
#         print(f"[SCRAPER FINAL] Before: {parsed_result}\nAfter conversion: {conversion_result}")
#         return parsed_result
                
    
#     def regex_parse_ingredient(self, text):
#         """Parse ingredient text using regex method (original implementation)."""
#         # Regex pattern to capture quantity, unit, and ingredient
#         pattern = r"""
#             ^\s*                                      # Start of string
#             (?P<quantity>                             # Quantity (e.g., 1/2, 0.75, 12, 1 1/2)
#                 \d+\s*/\s*\d+|                        # Fractions like 1/2
#                 \d+\.?\d*|                            # Decimals or integers
#                 \d+\s+\d+\s*/\s*\d+                   # Mixed numbers like "1 1/2"
#             )\s*
#             (?P<unit>                                 # Units (e.g., cup, g)
#                 tsp|tbsp|teaspoons?|tablespoons?|  # Explicit plurals
#                 cups?|grams?|g|kg|ml|oz|lbs?|      
#                 pinch(es)?|dash(es)?|pound|lb|     
#                 quarts?|pints?|gallons?|liters?|bunch|bottle|can|container|package
#             )?\s*                                     # Unit is optional
#             (?P<ingredient>                           # Ingredient name and notes
#                 .*?                                   # Non-greedy match
#             )
#             \s*$                                      # End of string
#         """.strip()

#         match = re.match(pattern, text, re.IGNORECASE | re.VERBOSE)
#         if not match:
#             return {"text": text, "error": "Could not parse"}

#         # Extract groups
#         quantity_str = match.group("quantity").strip()
#         unit = (match.group("unit") or "unit").lower().rstrip('s')  # Singularize unit
#         ingredient = match.group("ingredient").strip()

#         # Convert quantity to float
#         try:
#             if '/' in quantity_str:  # Handle fractions (e.g., "1/2")
#                 quantity = float(Fraction(quantity_str))
#             elif ' ' in quantity_str:  # Handle mixed numbers (e.g., "1 1/2")
#                 whole, fraction = quantity_str.split(' ')
#                 quantity = float(whole) + float(Fraction(fraction))
#             else:  # Handle whole numbers (e.g., "12")
#                 quantity = float(quantity_str)
#         except:
#             return {"text": text, "error": "Invalid quantity"}

#         # Clean ingredient name (remove symbols like *)
#         ingredient = re.sub(r"[^\w\s-]", "", ingredient).strip()

#         return {
#             "quantity": quantity,
#             "unit": unit,
#             "ingredient": ingredient
#         }

#     def extract_instructions(self):
#         instructions = []
#         step_tags = self.soup.find_all(["li", "p"], class_=lambda x: x and "instruction" in x.lower())
#         if step_tags:
#             for tag in step_tags:
#                 instructions.append(tag.text.strip())
#         return instructions if instructions else ["Instructions not found"]

#     def is_baking_recipe(self, ingredients, instructions):
#         baking_keywords = ["bake", "oven", "flour", "sugar", "butter", "yeast"]
#         combined_text = " ".join(ingredients + instructions).lower()
#         return any(keyword in combined_text for keyword in baking_keywords)

#     def find_next_page(self):
#         next_link = self.soup.find("a", string=re.compile(r"next|more|→", re.IGNORECASE))
#         if next_link and next_link.get("href"):
#             next_url = next_link["href"]
#             return next_url if next_url.startswith("http") else f"{self.base_url}{next_url}"
#         return None
    
#     def save_to_json(self, data, filename="scraped_recipe.json"):
#         try:
#             # Read existing data if the file exists
#             try:
#                 with open(filename, 'r') as f:
#                     existing_data = json.load(f)
#             except (FileNotFoundError, json.JSONDecodeError):
#                 existing_data = []

#             # Append new data
#             existing_data.append(data)

#             # Write data back to the file
#             with open(filename, 'w') as f:
#                 json.dump(existing_data, f, indent=4)
#             print(f"Data saved to {filename}")
#         except Exception as e:
#             print(f"Error saving data to JSON: {e}")

    
#     def scrape_recipe(self):
#         self.fetch_page()
#         title = self.extract_title()
#         raw_ingredients = self.extract_ingredients()
#         instructions = self.extract_instructions()

#         # Parse each ingredient
#         parsed_ingredients = []
#         for ingredient_text in raw_ingredients:
#             parsed = self.parse_ingredient(ingredient_text)
#             parsed_ingredients.append(parsed)

#         if self.is_baking_recipe(raw_ingredients, instructions):
#             result = {
#                 "title": title,
#                 "ingredients": parsed_ingredients,
#                 "instructions": instructions,
#                 "url": self.url
#             }
#             self.save_to_json(result)

#             return result

#         else:
#             return {"error": "Not a baking recipe."}
        
       
# # ✅ POST request (Accepts JSON body)
# @app.post("/scrape" ,response_model=RecipeResult)
# async def scrape_recipe(request: ScrapeRequest):
#     try:
#         scraper = BakingRecipeScraper(request.url)
#         result = scraper.scrape_recipe()
#         return result
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

# # ✅ GET request (Accepts URL as query parameter)
# @app.get("/scrape")
# async def scrape_recipe_get(url: str):
#     try:
#         scraper = BakingRecipeScraper(url)
#         result = scraper.scrape_recipe()
#         return result
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))  



from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, AnyUrl
from typing import Optional, List, Tuple, Dict, Union
import requests
from bs4 import BeautifulSoup
import re
import spacy
from fractions import Fraction
import json
from dataclasses import dataclass # Import dataclass for ParsedIngredient

app = FastAPI()

# =============================================================================
# NEW: ParsedIngredient Dataclass from final model.txt
# This structure holds parsed ingredient data, including character spans for NER training.
# =============================================================================
@dataclass
class ParsedIngredient:
    """Structure to hold parsed ingredient data"""
    quantity: float
    unit: str
    ingredient: str
    modifiers: List[str]
    original: str
    grams: Optional[float] = None
    # Character spans for NER training
    quantity_span: Optional[Tuple[int, int]] = None
    unit_span: Optional[Tuple[int, int]] = None
    ingredient_span: Optional[Tuple[int, int]] = None
    modifier_spans: List[Tuple[int, int]] = None

# =============================================================================
# UPDATED: Pydantic models to align with the new ParsedIngredient
# =============================================================================
class IngredientResult(BaseModel):
    quantity: float
    unit: str
    ingredient: str
    modifiers: List[str] = [] # Changed from 'notes' and 'size_modifier'
    original: str # Original text of the ingredient line
    grams: Optional[float] = None
    
    # Spans for NER - now optional as they are primarily for training, not API output
    quantity_span: Optional[Tuple[int, int]] = None
    unit_span: Optional[Tuple[int, int]] = None
    ingredient_span: Optional[Tuple[int, int]] = None
    modifier_spans: List[Tuple[int, int]] = []


class RecipeResult(BaseModel):
    title: str
    ingredients: List[IngredientResult]
    instructions: List[str]
    url: str

# =============================================================================
# NEW: IngredientParser Class from final model.txt
# This class handles both parsing and conversion to grams.
# =============================================================================
class IngredientParser:
    """Rule-based parser for extracting structured data from ingredient strings"""
    
    def __init__(self):
        # Initialize spaCy tokenizer
        try:
            self.nlp = spacy.load("en_core_web_sm")
        except OSError:
            # If model not available, create blank English model
            self.nlp = spacy.blank("en")
        
        # Comprehensive ingredient-specific conversion table
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

        # Standard volume unit conversions for fallback
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
        
        # Additional units that need recognition
        self.unit_conversions = {
            # Weight units (already in grams or convert to grams)
            'g': 1.0, 'gram': 1.0, 'grams': 1.0, 'gr': 1.0,
            'kg': 1000.0, 'kilogram': 1000.0, 'kilograms': 1000.0,
            'oz': 28.35, 'ounce': 28.35, 'ounces': 28.35,
            'lb': 453.59, 'pound': 453.59, 'pounds': 453.59, 'lbs': 453.59,
            
            # Volume units
            'ml': 1.0, 'milliliter': 1.0, 'milliliters': 1.0, 'millilitre': 1.0, 'millilitres': 1.0,
            'l': 1000.0, 'liter': 1000.0, 'liters': 1000.0, 'litre': 1000.0, 'litres': 1000.0,
            'cup': None, 'cups': None, 'c': None,  # Will be handled by ingredient-specific conversion
            'tablespoon': None, 'tablespoons': None, 'tbsp': None, 'tbs': None,
            'teaspoon': None, 'teaspoons': None, 'tsp': None,
            'fl oz': 30.0, 'fluid ounce': 30.0, 'fluid ounces': 30.0, 'floz': 30.0,
            'pint': None, 'pints': None, 'pt': None,
            'quart': None, 'quarts': None, 'qt': None,
            'gallon': None, 'gallons': None, 'gal': None,
            
            # Count-based units (need ingredient-specific conversion)
            'piece': None, 'pieces': None, 'pc': None, 'pcs': None,
            'item': None, 'items': None,
            'slice': None, 'slices': None,
            'clove': None, 'cloves': None,
            'stick': None, 'sticks': None,
            'can': None, 'cans': None, 'tin': None, 'tins': None,
            'package': None, 'packages': None, 'pkg': None, 'pkgs': None,
            'box': None, 'boxes': None,
            'jar': None, 'jars': None,
            'bottle': None, 'bottles': None,
            
            # Special cases
            'pinch': 0.6, 'pinches': 0.6,
            'dash': 0.6, 'dashes': 0.6,
            'handful': 40.0, 'handfuls': 40.0,
        }
        
        # Common modifiers that describe preparation
        self.modifiers = {
            'chopped', 'diced', 'minced', 'sliced', 'grated', 'shredded',
            'beaten', 'whipped', 'melted', 'softened', 'room temperature',
            'fresh', 'dried', 'frozen', 'canned', 'cooked', 'raw',
            'fine', 'coarse', 'roughly', 'finely', 'thinly', 'thickly',
            'peeled', 'seeded', 'hulled', 'trimmed', 'cleaned',
            'sifted', 'packed', 'leveled', 'heaped', 'rounded',
            'hot', 'cold', 'warm', 'cool', 'boiling', 'lukewarm',
            'extra virgin', 'virgin', 'light', 'dark', 'heavy',
            'unsalted', 'salted', 'sweet', 'bitter', 'sour',
            'ground', 'whole', 'half', 'quartered', 'cubed',
            'well-beaten', 'finely chopped', 'coarsely ground'
        }
        
        # Unicode fraction mappings
        self.unicode_fractions = {
            '¼': 0.25, '½': 0.5, '¾': 0.75,
            '⅐': 1/7, '⅑': 1/9, '⅒': 0.1,
            '⅓': 1/3, '⅔': 2/3, '⅕': 0.2,
            '⅖': 0.4, '⅗': 0.6, '⅘': 0.8,
            '⅙': 1/6, '⅚': 5/6, '⅛': 0.125,
            '⅜': 0.375, '⅝': 0.625, '⅞': 0.875
        }
        
        # Quantity word mappings
        self.quantity_words = {
            'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
            'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
            'dozen': 12, 'half': 0.5, 'quarter': 0.25
        }
        
        # Regex patterns for parsing
        self.patterns = {
            # Fraction patterns (including unicode)
            'fraction': r'(\d+)?\s*(\d+)/(\d+)',
            'unicode_fraction': r'[¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]',
            'decimal': r'(\d*\.?\d+)',
            'range': r'(\d+(?:\.\d+)?)\s*[-–—to]\s*(\d+(?:\.\d+)?)',
            
            # Unit patterns
            'unit': r'\b(' + '|'.join(re.escape(unit) for unit in self.unit_conversions.keys()) + r')\b',
            
            # Common quantity words
            'quantity_words': r'\b(a|an|one|two|three|four|five|six|seven|eight|nine|ten|dozen|half|quarter)\b',
        }
    
    def find_quantity_span(self, doc, text: str) -> Tuple[Optional[float], Optional[Tuple[int, int]]]:
        """Find quantity value and its character span in the original text"""
        text_lower = text.lower()
        
        # Check for unicode fractions first
        for token in doc:
            if token.text in self.unicode_fractions:
                # Check if there's a whole number before it
                if token.i > 0 and doc[token.i - 1].like_num:
                    whole = float(doc[token.i - 1].text)
                    fraction_val = self.unicode_fractions[token.text]
                    quantity = whole + fraction_val
                    start_char = doc[token.i - 1].idx
                    end_char = token.idx + len(token.text)
                    return quantity, (start_char, end_char)
                else:
                    quantity = self.unicode_fractions[token.text]
                    return quantity, (token.idx, token.idx + len(token.text))
        
        # Check for regular fractions
        fraction_match = re.search(self.patterns['fraction'], text)
        if fraction_match:
            whole, numerator, denominator = fraction_match.groups()
            whole = int(whole) if whole else 0
            fraction_value = whole + Fraction(int(numerator), int(denominator))
            quantity = float(fraction_value)
            return quantity, (fraction_match.start(), fraction_match.end())
        
        # Check for ranges (take average)
        range_match = re.search(self.patterns['range'], text)
        if range_match:
            start, end = range_match.groups()
            quantity = (float(start) + float(end)) / 2
            return quantity, (range_match.start(), range_match.end())
        
        # Check for decimal numbers
        for token in doc:
            if token.like_num and token.text.replace('.', '').isdigit():
                quantity = float(token.text)
                return quantity, (token.idx, token.idx + len(token.text))
        
        # Check for quantity words
        for token in doc:
            if token.text.lower() in self.quantity_words:
                quantity = self.quantity_words[token.text.lower()]
                return quantity, (token.idx, token.idx + len(token.text))
        
        # Default to 1 if no quantity found
        return 1.0, None
    
    def find_unit_span(self, doc, text: str) -> Tuple[Optional[str], Optional[Tuple[int, int]]]:
        """Find unit and its character span"""
        # Look for units in tokens
        for token in doc:
            if token.text.lower() in self.unit_conversions:
                return token.text.lower(), (token.idx, token.idx + len(token.text))
        
        # Look for multi-word units like "fl oz"
        for i in range(len(doc) - 1):
            two_word = f"{doc[i].text} {doc[i+1].text}".lower()
            if two_word in self.unit_conversions:
                start_char = doc[i].idx
                end_char = doc[i+1].idx + len(doc[i+1].text)
                return two_word, (start_char, end_char)
        
        return None, None
    
    def find_modifier_spans(self, doc, text: str) -> List[Tuple[str, Tuple[int, int]]]:
        """Find modifiers and their character spans"""
        found_modifiers = []
        
        # Single word modifiers
        for token in doc:
            if token.text.lower() in self.modifiers:
                modifier = token.text.lower()
                span = (token.idx, token.idx + len(token.text))
                found_modifiers.append((modifier, span))
        
        # Multi-word modifiers
        text_lower = text.lower()
        for modifier in sorted(self.modifiers, key=len, reverse=True):
            if ' ' in modifier and modifier in text_lower:
                start = text_lower.find(modifier)
                if start != -1:
                    end = start + len(modifier)
                    found_modifiers.append((modifier, (start, end)))
        
        # Remove duplicates and overlaps
        found_modifiers = self._remove_overlapping_spans(found_modifiers)
        
        return found_modifiers
    
    def _remove_overlapping_spans(self, spans: List[Tuple[str, Tuple[int, int]]]) -> List[Tuple[str, Tuple[int, int]]]:
        """Remove overlapping spans, keeping longer ones"""
        if not spans:
            return []
        
        # Sort by start position
        spans.sort(key=lambda x: x[1][0])
        
        non_overlapping = [spans[0]]
        
        for current in spans[1:]:
            last = non_overlapping[-1]
            # Check for overlap
            if current[1][0] < last[1][1]:
                # Keep the longer span
                if (current[1][1] - current[1][0]) > (last[1][1] - last[1][0]):
                    non_overlapping[-1] = current
            else:
                non_overlapping.append(current)
        
        return non_overlapping
    
    def find_ingredient_span(self, doc, text: str, quantity_span: Optional[Tuple[int, int]], 
                           unit_span: Optional[Tuple[int, int]], 
                           modifier_spans: List[Tuple[str, Tuple[int, int]]]) -> Tuple[str, Optional[Tuple[int, int]]]:
        """Find ingredient name and its span by excluding other components"""
        
        # Collect all used spans
        used_spans = []
        if quantity_span:
            used_spans.append(quantity_span)
        if unit_span:
            used_spans.append(unit_span)
        for _, span in modifier_spans:
            used_spans.append(span)
        
        # Find tokens that are not part of used spans
        ingredient_tokens = []
        for token in doc:
            token_start = token.idx
            token_end = token.idx + len(token.text)
            
            # Skip if token overlaps with any used span
            is_used = False
            for used_start, used_end in used_spans:
                if not (token_end <= used_start or token_start >= used_end):
                    is_used = True
                    break
            
            # Skip punctuation and whitespace-only tokens
            if not is_used and not token.is_punct and not token.is_space and token.text.strip():
                ingredient_tokens.append(token)
        
        if ingredient_tokens:
            # Get the span from first to last ingredient token
            start_char = ingredient_tokens[0].idx
            end_char = ingredient_tokens[-1].idx + len(ingredient_tokens[-1].text)
            ingredient_text = text[start_char:end_char].strip()
            
            # Clean up ingredient name
            ingredient_text = re.sub(r'[,;].*$', '', ingredient_text)
            ingredient_text = re.sub(r'\s+', ' ', ingredient_text).strip()
            
            return ingredient_text, (start_char, end_char)
        
        return "", None
    
    def parse_ingredient_string(self, ingredient_string: str) -> ParsedIngredient:
        """Parse a raw ingredient string into structured components with character spans"""
        original = ingredient_string
        doc = self.nlp(ingredient_string)
        
        # Extract components with spans
        quantity, quantity_span = self.find_quantity_span(doc, ingredient_string)
        unit, unit_span = self.find_unit_span(doc, ingredient_string)
        modifier_data = self.find_modifier_spans(doc, ingredient_string)
        modifiers = [mod for mod, _ in modifier_data]
        modifier_spans = [span for _, span in modifier_data]
        
        ingredient, ingredient_span = self.find_ingredient_span(
            doc, ingredient_string, quantity_span, unit_span, modifier_data
        )
        
        return ParsedIngredient(
            quantity=quantity,
            unit=unit or 'piece', # Default to 'piece' if no unit found
            ingredient=ingredient,
            modifiers=modifiers,
            original=original,
            quantity_span=quantity_span,
            unit_span=unit_span,
            ingredient_span=ingredient_span,
            modifier_spans=modifier_spans
        )
    
    def normalize_ingredient_name(self, ingredient: str) -> str:
        """Normalize ingredient name using aliases"""
        ingredient_lower = ingredient.lower().strip()
        
        # Check exact matches first
        if ingredient_lower in self.ingredient_aliases:
            return self.ingredient_aliases[ingredient_lower]
        
        # Check partial matches for multi-word ingredients
        for alias, normalized in self.ingredient_aliases.items():
            if alias in ingredient_lower:
                return normalized
        
        return ingredient_lower

    def convert_to_grams(self, parsed: ParsedIngredient) -> Optional[float]:
        """Convert parsed ingredient to grams using comprehensive conversion table"""
        ingredient_normalized = self.normalize_ingredient_name(parsed.ingredient)
        unit_lower = parsed.unit.lower()
        
        # First check comprehensive conversion table
        if ingredient_normalized in self.conversion_table:
            conversions = self.conversion_table[ingredient_normalized]
            
            # Handle special cup cases with modifiers
            if unit_lower in ['cup', 'cups', 'c']:
                if isinstance(conversions.get('cup'), dict):
                    # Check modifiers for specific conversions
                    for modifier in parsed.modifiers:
                        if modifier in conversions['cup']:
                            return parsed.quantity * conversions['cup'][modifier]
                    # Use default if no modifier matches
                    return parsed.quantity * conversions['cup'].get('default', conversions['cup'])
                elif 'cup' in conversions:
                    return parsed.quantity * conversions['cup']
            
            # Handle other units
            if unit_lower in conversions:
                conversion_factor = conversions[unit_lower]
                if isinstance(conversion_factor, (int, float)):
                    return parsed.quantity * conversion_factor
                elif isinstance(conversion_factor, dict):
                    # Handle size-based conversions (like eggs)
                    for modifier in parsed.modifiers:
                        if modifier in conversion_factor:
                            return parsed.quantity * conversion_factor[modifier]
                    # Fallback to default or first value if no specific modifier matches
                    return parsed.quantity * conversion_factor.get('default', list(conversion_factor.values())[0])
        
        # Fallback to basic unit conversions for weight units
        if unit_lower in self.unit_conversions:
            conversion_factor = self.unit_conversions[unit_lower]
            if conversion_factor is not None:
                return parsed.quantity * conversion_factor
        
        # Special handling for common ingredients not in conversion table
        if unit_lower in ['cup', 'cups', 'c']:
            # Default density approximation for unknown ingredients in cups
            return parsed.quantity * 120  # Average density for common ingredients
        elif unit_lower in ['tbsp', 'tablespoon', 'tablespoons']:
            return parsed.quantity * 15
        elif unit_lower in ['tsp', 'teaspoon', 'teaspoons']:
            return parsed.quantity * 5
        
        return None
    
    def parse_and_convert(self, ingredient_string: str) -> ParsedIngredient:
        """Parse ingredient string and convert to grams"""
        parsed = self.parse_ingredient_string(ingredient_string)
        parsed.grams = self.convert_to_grams(parsed)
        return parsed

# =============================================================================
# ScrapeRequest Model
# =============================================================================
class ScrapeRequest(BaseModel):
    url: AnyUrl

# =============================================================================
# UPDATED: BakingRecipeScraper Class
# Uses the new IngredientParser.
# =============================================================================
class BakingRecipeScraper:
    def __init__(self, url: str):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops
        self.ingredient_parser = IngredientParser() # Initialize the new parser
    
    def fetch_page(self):
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(self.url, headers=headers)
        response.encoding = 'utf-8'
        if response.status_code == 200:
            self.soup = BeautifulSoup(response.text, "html.parser")
        else:
            raise Exception(f"Failed to fetch page: {response.status_code}")

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

    def parse_ingredient(self, text: str) -> IngredientResult:
        """
        Parses a single ingredient string using the new IngredientParser
        and returns it as an IngredientResult Pydantic model.
        """
        parsed_data = self.ingredient_parser.parse_and_convert(text)
        
        # Convert ParsedIngredient dataclass to IngredientResult Pydantic model
        return IngredientResult(
            quantity=parsed_data.quantity,
            unit=parsed_data.unit,
            ingredient=parsed_data.ingredient,
            modifiers=parsed_data.modifiers,
            original=parsed_data.original,
            grams=parsed_data.grams,
            quantity_span=parsed_data.quantity_span,
            unit_span=parsed_data.unit_span,
            ingredient_span=parsed_data.ingredient_span,
            modifier_spans=parsed_data.modifier_spans
        )
                
    def extract_instructions(self):
        instructions = []
        step_tags = self.soup.find_all(["li", "p"], class_=lambda x: x and "instruction" in x.lower())
        if step_tags:
            for tag in step_tags:
                instructions.append(tag.text.strip())
        return instructions if instructions else ["Instructions not found"]

    def is_baking_recipe(self, ingredients, instructions):
        baking_keywords = ["bake", "oven", "flour", "sugar", "butter", "yeast", "dough", "batter", "cake", "cookie", "bread"]
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
            with open(filename, 'w', encoding='utf-8') as f: # Added encoding
                json.dump(existing_data, f, indent=4, ensure_ascii=False) # ensure_ascii=False for proper unicode
            print(f"Data saved to {filename}")
        except Exception as e:
            print(f"Error saving data to JSON: {e}")

    
    def scrape_recipe(self):
        self.fetch_page()
        title = self.extract_title()
        raw_ingredients = self.extract_ingredients()
        instructions = self.extract_instructions()

        # Parse each ingredient using the new parser
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
            # Convert IngredientResult objects to dictionaries for JSON serialization
            result['ingredients'] = [ing.dict() for ing in result['ingredients']]
            self.save_to_json(result)

            return result

        else:
            return {"error": "Not a baking recipe."}
        
       
# FastAPI Endpoints
@app.post("/scrape" ,response_model=RecipeResult)
async def scrape_recipe(request: ScrapeRequest):
    try:
        scraper = BakingRecipeScraper(str(request.url)) # Convert AnyUrl to string
        result = scraper.scrape_recipe()
        # If result is an error dict, raise HTTPException
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        return RecipeResult(**result) # Ensure the result matches the Pydantic model
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/scrape", response_model=RecipeResult)
async def scrape_recipe_get(url: str):
    try:
        scraper = BakingRecipeScraper(url)
        result = scraper.scrape_recipe()
        # If result is an error dict, raise HTTPException
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"])
        return RecipeResult(**result) # Ensure the result matches the Pydantic model
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

