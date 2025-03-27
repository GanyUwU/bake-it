from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
from fractions import Fraction

# Initialize FastAPI app
app = FastAPI()

# Define a Pydantic model for the incoming request
class ScrapeRequest(BaseModel):
    url: str

# Your scraping class remains mostly unchanged:
class BakingRecipeScraper:
    def __init__(self, url: str):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops

    def fetch_page(self):
        """Fetches the webpage content for a given URL."""
        headers = {"User-Agent": "Mozilla/5.0"}
        response = requests.get(self.url, headers=headers)
        if response.status_code == 200:
            self.soup = BeautifulSoup(response.text, "html.parser")
        else:
            raise Exception("Failed to fetch page")

    def extract_title(self):
        """Extracts the recipe title from the page."""
        title_tag = self.soup.find("h1") or self.soup.find("title")
        return title_tag.text.strip() if title_tag else "No title found"

    def extract_ingredients(self):
        """Extracts ingredients from the page using common HTML patterns."""
        ingredients = []
        # Primary method: Look for tags that include 'ingredient' in their class name.
        ingredient_tags = self.soup.find_all(["li", "span", "p"],
                                               class_=lambda x: x and "ingredient" in x.lower())
        if ingredient_tags:
            for tag in ingredient_tags:
                ingredients.append(tag.get_text(separator=" ", strip=True))
        # Fallback: Use semantic HTML if the above method returns nothing.
        if not ingredients or ingredients == ["Ingredients not found"]:
            heading = self.soup.find(lambda tag: tag.name in ["h2", "h3"] and "ingredient" in tag.get_text().lower())
            if heading:
                list_tag = heading.find_next(["ul", "ol"])
                if list_tag:
                    li_tags = list_tag.find_all("li")
                    for li in li_tags:
                        ingredients.append(li.get_text(separator=" ", strip=True))
        return ingredients if ingredients else ["Ingredients not found"]

    def parse_ingredient(self, text: str):
        """Parse ingredient text into structured data, handling fractions and units."""
        pattern = r"""
            ^\s*                                      # Start of string
            (?P<quantity>                             # Quantity (e.g., 1/2, 0.75, 12, 1 1/2)
                \d+\s*/\s*\d+|                        # Fractions like 1/2
                \d+\.?\d*|                            # Decimals or integers
                \d+\s+\d+\s*/\s*\d+                   # Mixed numbers like "1 1/2"
            )\s*
            (?P<unit>                                 # Units (e.g., cup, g)
                tsp|tbsp|teaspoon|tablespoon|
                cups?|grams?|g|kilograms?|kg|
                milliliters?|ml|ounces?|oz|lbs?|       # Allow plural/singular
                pinch|dash|pound|lb|quarts?|pints?|gallons?|
                liters?|bunch|bottle|can|container|package
            )?\s*                                     # Unit is optional
            (?P<ingredient>                           # Ingredient name and notes
                .*?                                   # Non-greedy match
            )
            \s*$                                      # End of string
        """.strip()

        match = re.match(pattern, text, re.IGNORECASE | re.VERBOSE)
        if not match:
            return {"text": text, "error": "Could not parse"}

        quantity_str = match.group("quantity").strip()
        unit = (match.group("unit") or "unit").lower().rstrip('s')
        ingredient = match.group("ingredient").strip()

        try:
            if ' ' in quantity_str and '/' in quantity_str:
                whole, fraction = quantity_str.split(' ')
                quantity = float(whole) + float(Fraction(fraction))
            elif '/' in quantity_str:
                quantity = float(Fraction(quantity_str))
            else:
                quantity = float(quantity_str)
        except Exception:
            return {"text": text, "error": "Invalid quantity"}

        ingredient = re.sub(r"[^\w\s-]", "", ingredient).strip()

        return {
            "quantity": quantity,
            "unit": unit,
            "ingredient": ingredient
        }

    def extract_instructions(self):
        """Extracts instructions from the page using common HTML patterns."""
        instructions = []
        step_tags = self.soup.find_all(["li", "p"], class_=lambda x: x and "instruction" in x.lower())
        if step_tags:
            for tag in step_tags:
                instructions.append(tag.text.strip())
        return instructions if instructions else ["Instructions not found"]

    def is_baking_recipe(self, ingredients, instructions):
        """Determines if the recipe is a baking recipe based on keywords."""
        baking_keywords = ["bake", "oven", "flour", "sugar", "butter", "yeast"]
        combined_text = " ".join(ingredients + instructions).lower()
        return any(keyword in combined_text for keyword in baking_keywords)

    def find_next_page(self):
        next_link = self.soup.find("a", string=re.compile(r"next|more|→", re.IGNORECASE))
        if next_link and next_link.get("href"):
            next_url = next_link["href"]
            return next_url if next_url.startswith("http") else f"{self.base_url}{next_url}"
        return None

    def scrape_recipe(self):
        """Runs the complete scraping process and returns structured recipe data."""
        self.fetch_page()
        title = self.extract_title()
        ingredients = self.extract_ingredients()
        instructions = self.extract_instructions()
        parsed_ingredients = [self.parse_ingredient(ing) for ing in ingredients]
        if self.is_baking_recipe(ingredients, instructions):
            return {
                "title": title,
                "ingredients": parsed_ingredients,
                "instructions": instructions,
                "url": self.url
            }
        else:
            return {"error": "Not a baking recipe."}

# Define a FastAPI endpoint
@app.post("/scrape")
def scrape_recipe(request: ScrapeRequest):
    url = request.url
    try:
        scraper = BakingRecipeScraper(url)
        result = scraper.scrape_recipe()
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Pydantic model for the request body
class ScrapeRequest(BaseModel):
    url: str
