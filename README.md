# 🌐 Shell-Automated Microservices Deployment on AWS

This project demonstrates a **production-style microservices architecture** deployed on AWS using **Shell Scripting and AWS CLI**.  
Each service runs on its own EC2 instance and is managed using **systemd**, while **Nginx acts as a reverse proxy** to route API traffic to backend services.

Instead of a single-server setup, the application is intentionally split into independent components to reflect **real-world DevOps and platform engineering practices**, including automation, service ownership, troubleshooting, and operational reliability.

---

## 🧩 Architecture Diagram

User / Browser
   |
   v
Route53 DNS (cloudkarna.in)
   |
   v
Frontend EC2
   |
   v
Nginx Reverse Proxy
   |
   +--> Catalogue Service EC2  ---> MongoDB EC2
   |
   +--> User Service EC2       ---> MongoDB EC2
   |
   +--> Cart Service EC2       ---> Redis EC2
   |
   +--> Shipping Service EC2   ---> MySQL EC2
   |
   +--> Payment Service EC2    ---> RabbitMQ EC2


---

## 🚀 What I Built (End-to-End)

### 🔹 Step 1: Infrastructure Setup
- Provisioned **multiple EC2 instances** using shell scripts and AWS CLI
- Assigned a **single responsibility per server** (frontend, services, databases)
- Captured and reused **public and private IPs**
- Configured **security groups** to allow only required traffic

📌 Why microservices?  
Independent services improve scalability, fault isolation, and operational ownership.

---

### 🔹 Step 2: Data & Messaging Layer
- Installed and configured:
  - MongoDB (catalogue, user)
  - Redis (cart)
  - MySQL (shipping)
  - RabbitMQ (payment)
- Restricted access so only required services can connect

📌 Databases and queues are isolated and never exposed publicly.

---

### 🔹 Step 3: Backend Microservices Deployment
- Deployed each microservice on a **dedicated EC2 instance**
- Installed required runtimes and dependencies
- Passed configuration using **environment variables**

📌 Each service is loosely coupled and independently manageable.

---

### 🔹 Step 4: Service Management with systemd
- Configured every backend service as a **systemd unit**
- Enabled auto-start on boot
- Enabled restart on failure
- Centralized logging via journalctl

📌 This mirrors how long-running services are handled in production Linux systems.

---

### 🔹 Step 5: Frontend & Nginx Reverse Proxy
- Installed **Nginx** on the frontend server
- Deployed static frontend content
- Configured reverse proxy rules to route API traffic to backend services

📌 Reverse proxy cleanly separates UI from business logic and hides backend internals.

---

### 🔹 Step 6: DNS Automation (Route53)
- Created DNS records automatically using AWS CLI
- Removed dependency on hardcoded IPs
- Enabled consistent access even after instance recreation

📌 DNS automation is critical for repeatable and reliable deployments.

---

## 🔁 End-to-End Flow

User → Route53 → Nginx (Frontend) → Backend Microservices → Databases 

- Static content served by Nginx
- API requests routed to correct service
- Backend services communicate securely using private IPs

---

## 🔍 Troubleshooting & Debugging
- Services initially failed due to systemd and environment variable issues
- Identified problems using:
  - systemctl
  - journalctl
  - ss / netstat
- Fixed port binding, permissions, and service definitions

📌 This reflects real production incident troubleshooting.

---

## ✅ Final Outcome
✔ All microservices running independently  
✔ Nginx routing validated  
✔ Secure inter-service communication  
✔ End-to-end order flow working  
✔ Health checks passing  
✔ Production-like behavior achieved  

---

## 🧠 Key Learnings
- Microservices deployment on AWS
- Shell scripting for automation
- Linux service management using systemd
- Nginx reverse proxy configuration
- Cloud networking and security groups
- Real-world DevOps troubleshooting

---

## 🚀 Future Enhancements
- Introduce Application Load Balancer (ALB)
- Enable HTTPS using ACM
- Containerize services using Docker
- Add CI/CD pipeline
- Automate infrastructure using Terraform

---

## 👤 Author
Naga Ajay Ragyari  
Cloud & DevOps Engineer  

GitHub: https://github.com/NagaAjay1812  
LinkedIn: https://www.linkedin.com/in/naga-ajay-ragyari-55381b295/
