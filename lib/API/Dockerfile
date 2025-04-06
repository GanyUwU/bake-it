FROM python:3.10

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
 # Download the spaCy model
RUN python -m spacy download en_core_web_sm

COPY . .

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]