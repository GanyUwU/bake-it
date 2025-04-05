# Bake-it 

Welcome to the Precise baking for bakers project! This repository contains an application, built using Daart and Python, respectively. The Application serves as a palce where users can convert baking recipes to precies measurements(grams). This is helpful as many website and recipes are in vague measurements. 

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Running the Project](#running-the-project)
- [License](#license)

## Requirements
- Dart (3.7.0)
- Python (3.10 or later)

## Installation

1. Clone the repository:
    ```bash
   git clone https://github.com/GanyUwU/bake-it.git
   cd bake-it
   ```
2. Navigate to the API directory and install the dependencies:

## Running the Project

1. Run the server while in API directory
   ```bash
   cd lib
   cd API
   uvicorn server:app --host 0.0.0.0 --port 8000  --reload
   ```
   This will start the Fast API server.
   
2.To start the app
  ```bash
  flutter run
  ```
  This will run the Flutter App. Run this in a new terminal.

## License

This project is licensed under the MIT License.

