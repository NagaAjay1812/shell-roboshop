# Shell-Automated Microservices Deployment on AWS

## Overview
This project shows how a microservices-based e-commerce application can be deployed on AWS with end-to-end automation using Shell Scripting and the AWS CLI. Each component runs on its own EC2 instance, services are managed with `systemd`, and Nginx is used as a reverse proxy to route API requests to the right backend service. DNS is automated with Route53, and the scripts are written to be repeatable and safe to re-run.

## What This Project Includes
- Automated EC2 provisioning using shell scripts + AWS CLI
- Public/private IP handling for inter-service communication
- Route53 DNS record creation through automation
- Nginx reverse proxy configuration for clean routing
- `systemd` units to run services like production (start/stop/restart, logs, auto-start on boot)
- Validation and troubleshooting checks built into the flow:
  - `systemctl` status checks
  - port/listening checks (`ss` / `netstat`)
  - service health checks using `curl /health`
- Centralized script logs + error handling + reusable helper functions
- Idempotent execution (scripts can be re-run without breaking the setup)

## Architecture
**Traffic Flow**
- User → Route53 DNS → Frontend EC2 → Nginx Reverse Proxy → Backend Microservices

**Microservices**
- catalogue
- user
- cart
- shipping
- payment

**Databases & Messaging**
- MongoDB
- MySQL
- Redis
- RabbitMQ

**AWS Infrastructure**
- EC2 (t3.micro)
- Route53
- Security Groups
- AWS CLI Automation

## Architecture Diagram (Mermaid)
> Paste this section into GitHub README (Mermaid supported) or Mermaid Live Editor. If Medium doesn’t render Mermaid, keep it as a diagram snippet or replace it with an image later.

```text
Mermaid source:
flowchart LR
    U[User/Browser] --> R53[Route53 DNS]
    R53 --> FE[Frontend EC2]
    FE --> NX[Nginx Reverse Proxy]
    NX --> CAT[Catalogue Service EC2]
    NX --> USR[User Service EC2]
    NX --> CRT[Cart Service EC2]
    NX --> SHP[Shipping Service EC2]
    NX --> PAY[Payment Service EC2]
    CAT --> MONGO[(MongoDB EC2)]
    USR --> MONGO
    CRT --> REDIS[(Redis EC2)]
    SHP --> MYSQL[(MySQL EC2)]
    PAY --> RAB[(RabbitMQ EC2)]
