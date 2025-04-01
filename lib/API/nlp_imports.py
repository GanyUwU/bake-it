# setup_nltk.py
import nltk
import spacy

# Download NLTK resources
nltk.download('punkt')
nltk.download('punkt_tab')  # Specific missing resource
nltk.download('stopwords')

# Download spaCy model
spacy.cli.download("en_core_web_sm")

print("NLP resources installed successfully!")