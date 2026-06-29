# TechNova

TechNova is a modern, lightweight Flask-based application designed to practice DevOps workflows, including automated testing, containerization, CI/CD pipelines, and infrastructure deployment.

## Tech Stack
* **Language:** Python
* **Web Framework:** Flask
* **Containerization:** Docker
* **CI/CD Pipeline:** Jenkins
* **Infrastructure as Code (IaC):** Terraform
* **Cloud Platform:** AWS EC2

## How to Run Locally

1. Make sure you are in the `technova-app` root directory.
2. Activate the Python virtual environment:
   * **Windows (PowerShell):** `.\venv\Scripts\Activate.ps1`
   * **macOS/Linux:** `source venv/bin/activate`
3. Start the Flask application server:
   ```bash
   python app/server.py
   ```
4. Open your browser and navigate to `http://localhost:5000/`.

## How to Run Tests

To execute the unit tests using `pytest`, run:
```bash
python -m pytest tests/ -v
```
