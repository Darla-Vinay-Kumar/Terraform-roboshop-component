# 🚀 Terraform RoboShop Component

Infrastructure as Code implementation for deploying a **RoboShop application component on AWS using Terraform**.

This project demonstrates how Terraform can automate the provisioning of compute resources, application images, load balancing, Auto Scaling, health checks, and application routing.

---

## 🏗️ Architecture

```text
                    Internet
                       │
                       ▼
              ┌─────────────────┐
              │   Application   │
              │ Load Balancer   │
              └────────┬────────┘
                       │
                Listener Rule
                       │
                       ▼
              ┌─────────────────┐
              │  Target Group   │
              └────────┬────────┘
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
        ┌──────────┐        ┌──────────┐
        │   EC2    │        │   EC2    │
        │ Instance │        │ Instance │
        └────┬─────┘        └────┬─────┘
             │                   │
             └─────────┬─────────┘
                       │
                       ▼
                Auto Scaling Group
                       │
                       ▼
              Target Tracking Policy
                 CPU Target: 75%
```

---

# 🛠️ Technologies Used

- AWS
- Terraform
- Amazon EC2
- Amazon AMI
- Application Load Balancer
- Target Groups
- Launch Templates
- Auto Scaling Groups
- Security Groups
- VPC
- AWS CLI
- Bash

---

# 📁 Project Structure

```text
Terraform-roboshop-component/
│
├── main.tf
├── data.tf
├── locals.tf
├── variables.tf
├── bootstrap.sh
└── README.md
```

---

# ⚙️ Infrastructure Components

## EC2

Terraform provisions an EC2 instance using:

- AMI
- Instance type
- Security Group
- Private subnet
- Common resource tags

---

## Application Image

After application configuration, the EC2 instance is stopped and an AMI is created from the configured instance.

The AMI is then used by the Launch Template.

---

## Launch Template

The Launch Template defines:

- AMI
- Instance type
- Security groups
- Instance tags
- Volume tags

The Launch Template can be updated when a new application AMI is created.

---

## Auto Scaling Group

The Auto Scaling Group provides:

- Minimum instances: `1`
- Desired instances: `1`
- Maximum instances: `10`
- Multiple private subnets
- Load balancer target registration
- Rolling instance refresh

---

## Application Load Balancer

The project creates an ALB Target Group with:

- HTTP protocol
- Application health checks
- Configurable health check path
- 10-second health check interval
- HTTP success codes `200-299`

---

## Auto Scaling Policy

Target tracking is configured using:

```text
Metric: ASGAverageCPUUtilization
Target: 75%
```

The Auto Scaling Group can automatically scale based on average CPU utilization.

---

# 🚀 Terraform Workflow

```text
Terraform Configuration
          │
          ▼
      terraform init
          │
          ▼
      terraform plan
          │
          ▼
     terraform apply
          │
          ▼
       EC2 Instance
          │
          ▼
    Application Setup
          │
          ▼
        Create AMI
          │
          ▼
     Launch Template
          │
          ▼
    Auto Scaling Group
          │
          ▼
      Target Group
          │
          ▼
     ALB Listener Rule
```

---

# 🧪 Prerequisites

Before running this project, install:

- Terraform
- AWS CLI
- Git

Configure AWS authentication securely.

Verify:

```bash
terraform version
aws --version
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

---

# 🔧 Configuration

Configure the required environment-specific values through Terraform variables and/or your existing shared infrastructure configuration.

**Never commit:**

```text
AWS Access Keys
AWS Secret Keys
Passwords
Private SSH Keys
Terraform state files
Secrets
```

Use secure mechanisms such as:

- IAM Roles
- AWS SSM Parameter Store
- AWS Secrets Manager
- Environment variables
- GitHub Actions Secrets

---

# ▶️ Deployment

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

---

# 🧹 Destroy Infrastructure

When the infrastructure is no longer required:

```bash
terraform destroy
```

> ⚠️ Review the Terraform plan carefully before destroying production infrastructure.

---

# 🔐 Security Best Practices

This project follows Infrastructure as Code principles, but production deployments should additionally use:

- IAM roles instead of hard-coded credentials
- AWS Systems Manager Session Manager instead of passwords
- Remote Terraform state
- State locking
- Secrets Manager / Parameter Store
- Least-privilege IAM policies
- Security group restrictions
- Terraform security scanning

Recommended security tools:

```text
Checkov
tfsec
Trivy
```

---

# 📚 Terraform Concepts Demonstrated

This project demonstrates practical usage of:

- Resources
- Data sources
- Variables
- Locals
- Dependencies
- Resource lifecycle
- Dynamic blocks
- Provisioners
- Launch Templates
- Auto Scaling
- Load Balancing
- Health Checks
- Resource tagging
- Infrastructure automation

---

# 🎯 Learning Objectives

The purpose of this project is to demonstrate how Terraform can be used to automate a production-style AWS application component.

Key areas covered:

- Infrastructure as Code
- AWS compute automation
- Immutable application images
- Auto Scaling
- Load balancing
- Health checks
- Rolling updates
- Terraform dependencies
- Reusable configuration
- Cloud infrastructure automation

---

# 👨‍💻 Author

**Darla Vinay Kumar**

DevOps Engineer | AWS | Terraform | Kubernetes | Docker | CI/CD | DevSecOps

GitHub: [Darla-Vinay-Kumar](https://github.com/Darla-Vinay-Kumar)

---

⭐ If you find this project useful, consider giving it a star.
