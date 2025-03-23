# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code into the container
COPY . .

# Tell Cloud Run which port to listen on (Cloud Run expects 8080)
EXPOSE 8080

# Run the app when the container starts (make sure your Flask app listens on 0.0.0.0:8080)
CMD ["python", "parser.py"]
