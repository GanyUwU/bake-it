from fractions import Fraction
from flask import Flask, request, jsonify
import requests
from bs4 import BeautifulSoup
import re

app = Flask(__name__)

class BakingRecipeScraper:
    def __init__(self, url):
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

    # def extract_ingredients(self):
    #     """Extracts ingredients from the page using common HTML patterns."""
    #     ingredients = []
    #     # Looking for tags that include 'ingredient' in their class name.
    #     ingredient_tags = self.soup.find_all(["li", "span", "p"],
    #      class_=lambda x: x and "ingredient" in x.lower())
    #     if ingredient_tags:
    #         for tag in ingredient_tags:
    #             ingredients.append(tag.text.strip())
        
        
    #     return ingredients if ingredients else ["Ingredients not found"]

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
    
    from fractions import Fraction

    def parse_ingredient(self, text):
        """Parse ingredient text into structured data, handling fractions and units."""
        # Regex pattern to capture quantity, unit, and ingredient
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

        # Extract groups
        quantity_str = match.group("quantity").strip()
        unit = (match.group("unit") or "unit").lower().rstrip('s')  # Singularize unit (e.g., "cups" → "cup")
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
        """Extracts instructions from the page using common HTML patterns."""
        instructions = []
        # Looking for tags that include 'instruction' in their class name.
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

        
    
        if self.is_baking_recipe(ingredients, instructions):
            return {
                "title": title,
                "ingredients": ingredients,
                "instructions": instructions
            }
        else:
            return {"error": "Not a baking recipe."}

@app.route('/scrape', methods=['POST'])
def scrape_endpoint():
    # Expect a JSON payload with a "url" field.
    data = request.get_json()
    url = data.get("url") 
    if not url:
        return jsonify({"error": "No URL provided."}), 400
    try:
        scraper = BakingRecipeScraper(url)
        result = scraper.scrape_recipe()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)








    