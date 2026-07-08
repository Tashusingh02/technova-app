# 🚀 TechNova Web Application

TechNova is a lightweight, highly secure Python Flask web application designed as a reference implementation for modern DevOps workflows. It demonstrates best practices in automated testing, containerization, security hardening, Infrastructure as Code (IaC), and automated CI/CD pipelines.

---

## 🛠️ Technology Stack

* **Application Core:** Python 3.11 & Flask 3.1.3
* **Production WSGI Server:** Gunicorn 22.0.0
* **Containerization:** Docker & Docker Compose
* **Infrastructure as Code (IaC):** Terraform (AWS provider)
* **CI/CD Automation:** Jenkins (Pipeline-as-code)
* **Webhook Tunneling:** ngrok
* **Unit Testing:** pytest

---

## 🚀 Quick Start Guide

### 1. Running Locally (Development Mode)
To run the application on your local machine using the Python virtual environment:

1. Navigate to the project root directory:
   ```powershell
   cd c:\Users\tashu\OneDrive\Pictures\Desktop\masthead\technova-app
   ```
2. Activate the virtual environment:
   * **Windows (PowerShell):** `.\venv\Scripts\Activate.ps1`
   * **macOS/Linux:** `source venv/bin/activate`
3. Run the development server:
   ```powershell
   python app/server.py
   ```
4. Access the API at `http://localhost:5000/`.

### 2. Running Local Unit Tests
To execute the automated unit tests, run:
```powershell
.\venv\Scripts\python -m pytest tests/ -v
```

---

## 🔒 Security Hardening

The application is built with security-first practices to remediate container and infrastructure vulnerabilities:

### A. Container Security Hardening (`Dockerfile`)
* **Non-Root Execution:** Rather than running as `root` (which presents high security risks), the container runs as a restricted system user `appuser`.
* **WSGI Production Server:** Replaced the Flask built-in development server with **Gunicorn** to handle concurrency, prevent Denial of Service (DoS) attacks, and secure request parsing.
* **Main Guard Protection:** The development server is wrapped in an `if __name__ == "__main__"` block to prevent it from launching in production environments when imported by Gunicorn.

### B. Compose Hardening (`docker-compose.yml`)
* **`no-new-privileges:true`**: Prevents the container processes from gaining new privileges via `setuid` or `setgid` binaries.
* **`read_only: true`**: Mounts the container's root filesystem as read-only, preventing attackers from downloading and executing malicious payloads on the disk.
* **`tmpfs: /tmp`**: Mounts a temporary, memory-backed writeable directory at `/tmp` to allow the Flask/Gunicorn runtime to write temporary files without making the entire filesystem writeable.

### C. Infrastructure Access Control (`infrastructure/main.tf`)
* **IP Restriction:** SSH port 22 is restricted to the developer's public IP address (`/32` CIDR block) instead of being open to the world (`0.0.0.0/0`). This completely mitigates SSH brute-force attacks from external actors.

---

## ☁️ Cloud Infrastructure (Terraform)

The infrastructure is managed declaratively via Terraform. To inspect or manage the AWS environment:

1. Initialize Terraform:
   ```powershell
   cd infrastructure/
   terraform init
   ```
2. Preview changes:
   ```powershell
   terraform plan
   ```
3. Apply changes (Deploy EC2 & Networking):
   ```powershell
   terraform apply -auto-approve
   ```
4. Get EC2 public IP output:
   ```powershell
   terraform output
   ```

---

## 🔄 CI/CD Pipeline (Jenkins & ngrok)

Every push to the `main` branch triggers an automated pipeline:
1. **GitHub webhook** forwards the push notification to the local Jenkins instance via the **ngrok tunnel**.
2. **Jenkins** runs the pipeline defined in the [Jenkinsfile](file:///c:/Users/tashu/OneDrive/Pictures/Desktop/masthead/technova-app/Jenkinsfile):
   * **Checkout:** Pulls the latest code.
   * **Test:** Installs dependencies and runs `pytest` unit tests.
   * **Docker Build:** Builds a tagged Docker image containing the Gunicorn production server.
   * **Docker Push:** Pushes the secure image to Docker Hub (`tashusingh02/technova-app`).
   * **Deploy to EC2:** Connects to the AWS EC2 instance via SSH, pulls the latest image, and restarts the container safely.

---

## 🛑 DevOps Lifecycle Management (Resume/Save Cost)

To prevent AWS costs and free up PC memory at the end of the day:

### End of Day Shutdown
```powershell
# 1. Destroy AWS resources
cd infrastructure
terraform destroy -auto-approve

# 2. Stop Jenkins Container
docker stop jenkins

# 3. Stop ngrok
# Press Ctrl + C in the ngrok terminal window
```

### Resume Development Next Day
```powershell
# 1. Start Jenkins
docker start jenkins

# 2. Start ngrok tunnel
ngrok http 8080 --domain=headstand-donated-uncaring.ngrok-free.dev

# 3. Deploy AWS resources
cd infrastructure
terraform apply -auto-approve

# 4. Fetch public IP
terraform output

# 5. Update credentials
# Log into http://localhost:8080/ -> Manage Jenkins -> Credentials -> Global.
# Edit the 'ec2-public-ip' secret with the new public IP from step 4.
```
