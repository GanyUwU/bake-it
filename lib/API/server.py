from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
from fractions import Fraction
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import spacy
from spacy.matcher import Matcher
import json


app = FastAPI()

class IngredientParser:
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
        self.unit_map = {
        # Singular and plural forms
        "tsp": "teaspoon", "teaspoon": "teaspoon", "teaspoons": "teaspoon",
        "tbsp": "tablespoon", "tablespoon": "tablespoon", "tablespoons": "tablespoon",
        "cup": "cup", "cups": "cup",
        "gram": "gram", "grams": "gram", "g": "gram",
        "ounce": "ounce", "oz": "ounce", "ounces": "ounce",
        "pound": "pound", "lb": "pound", "lbs": "pound",
        "ml": "milliliter", "milliliter": "milliliter", "milliliters": "milliliter",
        "liter": "liter", "liters": "liter", "l": "liter",
        "pinch": "pinch", "pinches": "pinch",
        "dash": "dash", "dashes": "dash",
        # Add more as needed
        }
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
        
        # Existing patterns
        self.matcher.add("FRACTION_UNIT", [
            [{"TEXT": {"IN": list(self.fraction_map.keys())}}, {"LOWER": {"IN": list(self.unit_map.keys())}}],
            [{"LIKE_NUM": True}, {"LOWER": {"IN": list(self.unit_map.keys())}}]
        ])

    def _normalize_unit(self, unit):
        """Convert abbreviations to standardized form"""
        return self.unit_map.get(unit.lower(), unit).rstrip('s')

    def parse(self, text):
        doc = self.nlp(text)
        matches = self.matcher(doc)
        
        quantity = 1.0
        unit = "unit"
        ingredient = []
        matched_span = None
        
        # First check for combined numbers (e.g. "1 ¾")
        for match_id, start, end in matches:
            span = doc[start:end]
            if self.nlp.vocab.strings[match_id] == "COMBINED_NUMBER":
                whole_number = float(span[0].text)
                fraction = self.fraction_map.get(span[1].text, 0.0)
                quantity = whole_number + fraction
                # Look ahead for unit
                if end < len(doc) and doc[end].text.lower() in self.unit_map:
                    unit = self._normalize_unit(doc[end].text)
                    matched_span = doc[start:end+1]
                break
            else:
                # Handle regular matches
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
        
        # Get remaining tokens as ingredient
        for token in doc:
            if not matched_span or token not in matched_span:
                if token.pos_ in ["NOUN", "PROPN"] or token.text.lower() not in self.nlp.Defaults.stop_words:
                    ingredient.append(token.text)
        
        return {
            "quantity": quantity,
            "unit": unit,
            "ingredient": " ".join(ingredient)
        }

# ✅ Define a request model
class ScrapeRequest(BaseModel):
    url: str



# ✅ Fix the class initialization issue
class BakingRecipeScraper:
    def __init__(self, url: str):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops
        self.ingredient_parser = IngredientParser()
    
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
        ingredients = []
        ingredient_tags = self.soup.find_all(["li", "span", "p"], class_=lambda x: x and "ingredient" in x.lower())

        if ingredient_tags:
            for tag in ingredient_tags:
                ingredients.append(tag.get_text(separator=" ", strip=True))

        if not ingredients or ingredients == ["Ingredients not found"]:
            # Look for a heading (h2 or h3) containing "ingredient" in its text.
            heading = self.soup.find(lambda tag: tag.name in ["h2", "h3"] and "ingredient" in tag.get_text().lower())
            if heading:
                # Try to find the next sibling list (ul or ol) that likely holds the ingredients.
                list_tag = heading.find_next(["ul", "ol"])
                if list_tag:
                    li_tags = list_tag.find_all("li")
                    for li in li_tags:
                        ingredients.append(li.get_text(separator=" ", strip=True))
        return ingredients if ingredients else ["Ingredients not found"]

    def parse_ingredient(self, text):
        
       # Use the ingredient parser to get quantity/unit/ingredient
        parsed_result = self.ingredient_parser.parse(text)  # <-- This returns a dict
        
        # Then standardize the ingredient name
        # if parsed_result.get("ingredient"):
        #     standardized = self.nlp_processor.identify_ingredient(parsed_result["ingredient"])
        #     if standardized:
        #         parsed_result["ingredient"] = standardized
                
        parsed_result["text"] = text
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
        
        
# ✅ POST request (Accepts JSON body)
@app.post("/scrape")
async def scrape_recipe(request: ScrapeRequest):
    try:
        scraper = BakingRecipeScraper(request.url)
        result = scraper.scrape_recipe()
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ✅ GET request (Accepts URL as query parameter)
@app.get("/scrape")
async def scrape_recipe_get(url: str):
    try:
        scraper = BakingRecipeScraper(url)
        result = scraper.scrape_recipe()
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))