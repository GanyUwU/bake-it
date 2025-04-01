from fractions import Fraction
from flask import Flask, request, jsonify
import requests
from bs4 import BeautifulSoup
import re
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import spacy



class NLPIngredientProcessor:
    def __init__(self):
        # Download required NLTK resources (one-time setup)
        try:
            nltk.data.find('tokenizers/punkt')
        except LookupError:
            nltk.download('punkt')
            
        try:
            nltk.data.find('corpora/stopwords')
        except LookupError:
            nltk.download('stopwords')
            
        # Load spaCy model for more advanced NLP (uncomment if using spaCy)
        self.nlp = spacy.load("en_core_web_sm")
        
        # Common ingredients and their standard forms
        self.ingredients_dict = {
            # Basic baking ingredients
            "flour": ["all-purpose flour", "bread flour", "cake flour", "pastry flour", "wheat flour", "all purpose flour"],
            "sugar": ["granulated sugar", "white sugar", "caster sugar", "table sugar"],
            "brown sugar": ["light brown sugar", "dark brown sugar", "demerara sugar"],
            "powdered sugar": ["confectioners sugar", "icing sugar", "confectioners' sugar"],
            "butter": ["unsalted butter", "salted butter", "margarine", "butter substitute"],
            "eggs": ["egg", "egg whites", "egg yolks", "large eggs", "medium eggs"],
            "milk": ["whole milk", "skim milk", "dairy milk", "almond milk", "soy milk", "oat milk"],
            "oil": ["vegetable oil", "canola oil", "olive oil", "coconut oil", "sunflower oil"],
            "vanilla": ["vanilla extract", "vanilla essence", "vanilla flavoring", "vanillin"],
            "salt": ["table salt", "sea salt", "kosher salt", "himalayan salt"],
            "baking powder": ["double-acting baking powder"],
            "baking soda": ["bicarbonate of soda", "sodium bicarbonate", "bicarb soda"],
            "cocoa powder": ["unsweetened cocoa", "dutch process cocoa", "cacao powder"],
            "chocolate": ["chocolate chips", "chocolate chunks", "dark chocolate", "milk chocolate", "white chocolate", "semi-sweet chocolate"],
            "nuts": ["walnuts", "almonds", "pecans", "hazelnuts", "peanuts", "cashews", "pistachios"],
            "honey": ["raw honey", "clover honey", "pure honey"],
            "maple syrup": ["pure maple syrup", "maple extract", "maple flavoring"],
            "cinnamon": ["ground cinnamon", "cinnamon powder", "cinnamon sticks"],
            "oats": ["rolled oats", "quick oats", "old-fashioned oats", "instant oats"]
        }
        
        self.stop_words = set(stopwords.words('english'))
        
    def preprocess_text(self, text):
        """Clean and tokenize ingredient text."""
        # Convert to lowercase
        text = text.lower()
        
        # Remove punctuation except for / in fractions
        text = re.sub(r'[^\w\s/]', '', text)
        
        # Tokenize
        tokens = word_tokenize(text)
        
        # Remove stop words (except 'of' which is important for ingredients)
        filtered_tokens = [w for w in tokens if w not in self.stop_words or w == 'of']
        
        return filtered_tokens
        
    def identify_ingredient(self, ingredient_text):
        """Use NLP techniques to identify the main ingredient."""
        # Preprocess the text
        tokens = self.preprocess_text(ingredient_text)
        
        # First, check for direct matches in our ingredients dictionary
        for standard_name, variations in self.ingredients_dict.items():
            # Check if standard name appears in tokens
            if standard_name in tokens or any(variation in ingredient_text.lower() for variation in variations):
                return standard_name
                
        # If no direct match, try to find the main ingredient by removing measuring words
        measuring_words = ["cup", "cups", "tablespoon", "tablespoons", "tbsp", "teaspoon", 
                           "teaspoons", "tsp", "gram", "grams", "g", "ounce", "ounces", "oz"]
        content_tokens = [token for token in tokens if token not in measuring_words]
        
        # The main ingredient is often the first non-measurement word
        # OR it follows "of" as in "2 cups of flour"
        main_ingredient = None
        
        # Check for "of" pattern (e.g., "2 cups of flour")
        if "of" in content_tokens:
            of_index = content_tokens.index("of")
            if of_index < len(content_tokens) - 1:
                main_ingredient = content_tokens[of_index + 1]
        # If no "of" pattern, take the first token that's not a number
        else:
            for token in content_tokens:
                if not token.replace('.', '', 1).isdigit():  # Skip numbers
                    main_ingredient = token
                    break
        
        # If we identified a main ingredient, check for matches
        if main_ingredient:
            for standard_name, variations in self.ingredients_dict.items():
                if main_ingredient in variations or main_ingredient == standard_name:
                    return standard_name
                    
            # If it's not in our variations but seems to be a valid ingredient, return it
            return main_ingredient
            
        # If all else fails
        return None
    
    # Using spaCy for more advanced NLP (optional)
    def identify_ingredient_with_spacy(self, ingredient_text):
        """Use spaCy for ingredient identification."""
        # Make sure you've installed spaCy and downloaded a model:
        # pip install spacy
        # python -m spacy download en_core_web_sm
        
        doc = self.nlp(ingredient_text.lower())
        
        # Extract nouns which are likely to be ingredients
        nouns = [token.text for token in doc if token.pos_ == "NOUN"]
        
        # Check nouns against our ingredient dictionary
        for noun in nouns:
            for standard_name, variations in self.ingredients_dict.items():
                if noun == standard_name or any(noun in var for var in variations):
                    return standard_name
        
        # If no match but we found nouns, return the first one
        if nouns:
            return nouns[0]
            
        return None



class BakingRecipeScraper:
    def __init__(self, url):
        self.url = url
        self.soup = None
        self.base_url = "/".join(url.split("/")[:3])
        self.max_pages = 3  # Prevent infinite loops
        self.nlp_processor = NLPIngredientProcessor()

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
       
        # Add NLP standardization
        standardized_ingredient = self.nlp_processor.identify_ingredient(ingredient)
        if standardized_ingredient:
            final_ingredient = standardized_ingredient
        else:
            final_ingredient = ingredient

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
        raw_ingredients = self.extract_ingredients()
        instructions = self.extract_instructions()

        # Parse each ingredient
        parsed_ingredients = []
        for ingredient_text in raw_ingredients:
            parsed = self.parse_ingredient(ingredient_text)
            parsed_ingredients.append(parsed)

        
    
        if self.is_baking_recipe(raw_ingredients, instructions):
            return {
                "title": title,
                "ingredients": parsed_ingredients,
                "instructions": instructions
            }
        else:
            return {"error": "Not a baking recipe."}


app = Flask(__name__)

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
    app.run(host='0.0.0.0', port=5000)

