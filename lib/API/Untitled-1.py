
from flask import Flask, request, jsonify
import requests
import re
from bs4 import BeautifulSoup
from fractions import Fraction

app = Flask(__name__)

class RobustBakingScraper:
    def __init__(self, url):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops

    def fetch_page(self, url):
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            return BeautifulSoup(response.text, "html.parser")
        except Exception as e:
            raise Exception(f"Failed to fetch page: {str(e)}")

    def extract_title(self):
        title_tag = self.soup.find("h1") or self.soup.find("title")
        return title_tag.text.strip() if title_tag else "Untitled Recipe"

    # def extract_ingredients(self):
    #     ingredients = []
    #     # Case 1: Directly target common ingredient classes (e.g., loveandlemons.com)
    #     ingredient_tags = self.soup.find_all(class_=re.compile(r"wprm-recipe-ingredient|ingredient", re.IGNORECASE))
    #     # Case 2: Fallback to semantic HTML
    #     if not ingredient_tags:
    #         heading = self.soup.find(lambda tag: tag.name in ["h2", "h3"] and "ingredient" in tag.text.lower())
    #         if heading:
    #             list_tags = heading.find_next(["ul", "ol"])
    #             ingredient_tags = list_tags.find_all("li") if list_tags else []
    #     # Case 3: Manual override for specific sites
    #     if "loveandlemons.com" in self.url:
    #         ingredient_tags = self.soup.select("li.wprm-recipe-ingredient")
    #     for tag in ingredient_tags:
    #         text = tag.get_text(separator=" ", strip=True)
    #         ingredients.append(text)
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
                                                
    # def parse_ingredient(self, text):
    #     # Simplified regex for common patterns (e.g., "1 cup sugar" or "200g flour")
    #     pattern = r"""
    #         (^\d+\.?\d*)\s*     # Quantity
    #         (tsp|tbsp|cup|g|kg|ml|oz|lb)?\s*  # Unit
    #         (.+)                # Ingredient name
    #     """.strip()
    #     match = re.match(pattern, text, re.IGNORECASE | re.VERBOSE)
    #     if match:
    #         return {
    #             "quantity": float(match.group(1)),
    #             "unit": (match.group(2) or "unit").lower(),
    #             "ingredient": match.group(3).strip()
    #         }
    #     return {"text": text, "error": "Could not parse"}
    
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
    
    #To fetch the instructions from the page
    def extract_instructions(self):
        """Extracts instructions from the page using common HTML patterns."""
        instructions = []
        # Looking for tags that include 'instruction' in their class name.
        step_tags = self.soup.find_all(["li", "p"], class_=lambda x: x and "instruction" in x.lower())
        if step_tags:
            for tag in step_tags:
                instructions.append(tag.text.strip())
        return instructions if instructions else ["Instructions not found"]

    def find_next_page(self):
        next_link = self.soup.find("a", string=re.compile(r"next|more|→", re.IGNORECASE))
        if next_link and next_link.get("href"):
            next_url = next_link["href"]
            return next_url if next_url.startswith("http") else f"{self.base_url}{next_url}"
        return None

    def scrape_recipe(self):
        try:
            self.soup = self.fetch_page(self.url)
            title = self.extract_title()
            ingredients = []
            page_count = 0

            while self.soup and page_count < self.max_pages:
                ingredients.extend(self.extract_ingredients())
                next_page_url = self.find_next_page()
                if not next_page_url:
                    break
                self.soup = self.fetch_page(next_page_url)
                page_count += 1

            parsed_ingredients = [self.parse_ingredient(ing) for ing in ingredients]
            return {"title": title, "ingredients": parsed_ingredients, "url": self.url}
        except Exception as e:
            return {"error": str(e)}

@app.route('/scrape', methods=['POST'])
def scrape_endpoint():
    data = request.get_json()
    url = data.get("url")
    if not url:
        return jsonify({"error": "URL is required"}), 400
    try:
        scraper = RobustBakingScraper(url)
        result = scraper.scrape_recipe()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
