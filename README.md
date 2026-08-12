# 🚗 ChaloChalo

### India's Intercity Carpool & Daily Office Commute Platform

ChaloChalo is a web-based carpooling platform designed for **intercity travel and daily office commuting**.

The platform allows users to:

* Create an account and manage their profile
* Publish rides
* Search for available rides
* View ride details
* Book available seats
* Manage bookings
* Manage wallet and transactions
* Receive notifications
* Use AI-powered features through a self-hosted Ollama runtime

The application is designed as a **responsive web application** with a mobile-like experience, without requiring a native Android or iOS application.

---

# 📋 Table of Contents

* [Project Overview](#-project-overview)
* [Key Objectives](#-key-objectives)
* [Features](#-features)
* [System Architecture](#-system-architecture)
* [Application Architecture](#-application-architecture)
* [Infrastructure Architecture](#-infrastructure-architecture)
* [Technology Stack](#-technology-stack)
* [Repository Structure](#-repository-structure)
* [Application Request Flow](#-application-request-flow)
* [Core Services](#-core-services)
* [Database Architecture](#-database-architecture)
* [OCI Infrastructure](#-oci-infrastructure)
* [Always Free Policy](#-always-free-policy)
* [PAYG Account Strategy](#-payg-account-strategy)
* [Terraform](#-terraform)
* [OCI Authentication](#-oci-authentication)
* [SSH Access](#-ssh-access)
* [Ollama](#-ollama)
* [Local Development](#-local-development)
* [Deployment](#-deployment)
* [Environment Variables](#-environment-variables)
* [Security](#-security)
* [Capacity Handling](#-capacity-handling)
* [Cost Protection](#-cost-protection)
* [Backup & Recovery](#-backup--recovery)
* [Troubleshooting](#-troubleshooting)
* [Production Hardening](#-production-hardening)
* [Development Roadmap](#-development-roadmap)

---

# 🎯 Project Overview

ChaloChalo is designed around two primary use cases:

### 1. Intercity Carpool

Users travelling between cities can publish their planned journey and offer available seats to other users.

Example:

```text
Noida
   ↓
Delhi
   ↓
Chandigarh
```

A driver can publish:

```text
From: Noida
To: Chandigarh
Date: Saturday
Time: 06:00 AM
Available Seats: 3
```

Passengers can search for the ride and request/book a seat.

---

### 2. Daily Office Commute

Users can also use the platform for regular office commuting.

Example:

```text
Home
  ↓
Office
  ↓
Home
```

Future versions can support recurring rides such as:

```text
Monday → Friday
08:30 AM
Home → Office
```

---

# 🎯 Key Objectives

The project has the following architectural objectives:

1. Keep infrastructure cost as close to **₹0 as possible using Always Free resources**.
2. Use **PAYG only as the OCI account model**, not as permission to use paid infrastructure.
3. Avoid paid fallback resources.
4. Use open-source technologies wherever practical.
5. Use a responsive web application instead of native mobile applications.
6. Keep the database private.
7. Run the AI layer locally using Ollama.
8. Provision infrastructure using Terraform.
9. Keep application services modular and scalable.

---

# ✨ Features

## Authentication

* User registration
* Login
* Authentication
* Token/session management
* Password management
* User profile

## Ride Management

* Publish ride
* Search rides
* View ride details
* Manage available seats
* Ride lifecycle management
* Ride cancellation

## Booking

* Search available rides
* Select seats
* Create booking
* Cancel booking
* Track booking status

## Wallet

* Wallet balance
* Wallet transactions
* Booking-related transactions
* Transaction history

## Notifications

The architecture supports:

* Booking notifications
* Ride reminders
* Cancellation notifications
* Future email/SMS/push integrations

## AI

The platform can use **Ollama** for local AI functionality.

Possible future use cases:

* Ride recommendations
* Travel assistant
* Natural-language ride search
* User support assistant
* FAQ assistant
* RAG-based application assistant

---

# 🏗 System Architecture

High-level architecture:

```text
                         ┌─────────────────────┐
                         │       USER          │
                         │ Browser / Mobile UI │
                         └──────────┬──────────┘
                                    │
                                  HTTPS
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │       NGINX         │
                         │ Reverse Proxy / API │
                         │       Gateway       │
                         └──────────┬──────────┘
                                    │
                  ┌─────────────────┼──────────────────┐
                  │                 │                  │
                  ▼                 ▼                  ▼
             ┌─────────┐       ┌─────────┐       ┌──────────┐
             │  Auth   │       │  User   │       │   Ride   │
             │ Service │       │ Service │       │ Service  │
             └────┬────┘       └────┬────┘       └────┬─────┘
                  │                 │                  │
                  └─────────────────┼──────────────────┘
                                    │
                                    ▼
                             ┌──────────────┐
                             │   Booking    │
                             │   Service    │
                             └──────┬───────┘
                                    │
                          ┌─────────┴──────────┐
                          │                    │
                          ▼                    ▼
                   ┌──────────────┐      ┌────────────┐
                   │ OCI MySQL    │      │   Ollama   │
                   │  MySQL.Free  │      │ Local LLM  │
                   └──────────────┘      └────────────┘
```

---

# 🧩 Application Architecture

The application is logically divided into multiple services.

```text
Frontend
   │
   ▼
Nginx / API Gateway
   │
   ├── Auth Service
   │
   ├── User Service
   │
   ├── Ride Service
   │
   ├── Booking Service
   │
   ├── Wallet / Transaction
   │
   └── Notification / Background Jobs
            │
            ├──────────────► MySQL
            │
            └──────────────► Ollama
```

## Auth Service

Responsible for:

* Registration
* Login
* Authentication
* Token validation
* Password management

Example:

```text
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
POST /api/auth/logout
```

---

## User Service

Responsible for:

* User profile
* User preferences
* Profile updates
* User information

Example:

```text
GET    /api/users/me
PUT    /api/users/me
GET    /api/users/{id}
```

---

## Ride Service

The ride service is the core business service.

Responsibilities:

* Publish rides
* Search rides
* Update rides
* Cancel rides
* Manage seats
* Ride details

Example:

```text
POST   /api/rides
GET    /api/rides
GET    /api/rides/{id}
PUT    /api/rides/{id}
DELETE /api/rides/{id}
```

---

## Booking Service

Responsible for:

* Booking seats
* Booking status
* Cancellation
* Seat availability
* Booking history

Example:

```text
POST   /api/bookings
GET    /api/bookings
GET    /api/bookings/{id}
POST   /api/bookings/{id}/cancel
```

---

## Wallet Service

Responsible for:

* Wallet balance
* Transactions
* Booking-related payments
* Transaction history

Example:

```text
GET  /api/wallet
GET  /api/wallet/transactions
```

---

# 🗄 Database Architecture

The application uses **MySQL** as the transactional database.

Logical database domains:

```text
                    MySQL
                      │
       ┌──────────────┼──────────────┐
       │              │              │
       ▼              ▼              ▼
    Identity        Rides         Booking
       │              │              │
       ▼              ▼              ▼
    Users          Routes         Passengers
    Roles          Stops          Status
    Profiles       Seats
                      │
                      ▼
                   Wallet
                      │
                      ▼
                Transactions
```

Representative entities:

```text
users
user_roles
profiles

rides
ride_routes
ride_stops
ride_seats

bookings
booking_passengers
booking_status_history

wallets
wallet_transactions

notifications
audit_logs
```

The exact database schema should be maintained through migrations.

---

# ☁️ OCI Infrastructure Architecture

The infrastructure is deployed on Oracle Cloud Infrastructure.

```text
                         Internet
                            │
                            ▼
                   ┌────────────────┐
                   │ Internet       │
                   │ Gateway        │
                   └───────┬────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │       VCN            │
                │    10.0.0.0/16       │
                │                      │
                │  ┌────────────────┐  │
                │  │ Public Subnet  │  │
                │  │ 10.0.1.0/24    │  │
                │  │                │  │
                │  │ A1 VM          │  │
                │  │ 2 OCPU / 12 GB │  │
                │  └───────┬────────┘  │
                │          │            │
                │          │ TCP 3306   │
                │          ▼            │
                │  ┌────────────────┐  │
                │  │ Private Subnet │  │
                │  │ 10.0.2.0/24    │  │
                │  │                │  │
                │  │ MySQL.Free     │  │
                │  │ 50 GB          │  │
                │  └────────────────┘  │
                └──────────────────────┘
```

---

# 🖥 Compute

The application VM uses:

```text
Shape:
VM.Standard.A1.Flex

OCPU:
2

Memory:
12 GB

Architecture:
ARM64
```

The VM hosts:

```text
Docker
 ├── Nginx
 ├── FastAPI services
 └── Ollama
```

---

# 🗄 OCI MySQL

Database configuration:

```text
Shape:
MySQL.Free

Storage:
50 GB

Network:
Private subnet

Public IP:
Disabled

High Availability:
Disabled
```

The database is not directly exposed to the Internet.

Only the application subnet should be able to access:

```text
TCP 3306
```

---

# 💰 Always Free Policy

This project has a strict infrastructure rule:

> **PAYG account, Always Free infrastructure.**

PAYG is used as the OCI account model.

It does **not** mean that paid resources are allowed.

## Allowed

```text
VM.Standard.A1.Flex
2 OCPU
12 GB RAM

MySQL.Free
50 GB

VCN
Subnets
Internet Gateway
```

## Not allowed as fallback

```text
❌ 4 OCPU / 24 GB A1
❌ Paid Compute shapes
❌ Paid MySQL
❌ Paid Load Balancer
❌ Paid NAT Gateway
❌ Paid AI services
❌ Paid database services
❌ Paid capacity to solve A1 capacity errors
```

---

# 💳 PAYG Account Strategy

The account may be upgraded to PAYG to remove the Free Tier account restriction.

However:

```text
PAYG
  │
  ├── Always Free resource
  │       └── ✅ ChaloChalo
  │
  └── Paid resource
          └── ❌ Not allowed
```

Important:

**PAYG does not guarantee A1 capacity.**

If OCI reports:

```text
Out of capacity for shape VM.Standard.A1.Flex
```

the correct response is:

```text
Try another Availability Domain
        ↓
Check AD-2
        ↓
Check AD-3
        ↓
Wait if necessary
```

Not:

```text
4 OCPU / 24 GB
        ↓
Paid
```

---

# 🌍 Region and Availability Domain

The Always Free deployment should remain in the OCI **home region**.

The A1 availability domain is configurable:

```hcl
variable "a1_availability_domain" {
  type = string
}
```

Example:

```hcl
a1_availability_domain = "ujaX:AP-MUMBAI-1-AD-1"
```

If AD-1 has no A1 capacity, the deployment can try another availability domain in the same home region.

Terraform does not automatically retry another AD after an OCI capacity failure, so a future pre-flight script can perform:

```text
AD-1
 ↓
AD-2
 ↓
AD-3
```

and select an available AD.

---

# 🏗 Terraform

Terraform manages the OCI infrastructure.

Recommended structure:

```text
infrastructure/
└── terraform/
    ├── versions.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── .gitignore
```

Terraform is responsible for:

```text
OCI Provider
VCN
Internet Gateway
Route Tables
Security Lists
Public Subnet
Private Subnet
A1 VM
MySQL
Outputs
Always Free validation
```

---

# 🔐 Terraform Always Free Safety Check

The Terraform configuration should enforce the intended configuration.

Example:

```hcl
locals {
  compute_shape     = "VM.Standard.A1.Flex"
  compute_ocpus     = 2
  compute_memory_gb = 12

  mysql_shape      = "MySQL.Free"
  mysql_storage_gb = 50
}
```

A validation check can ensure:

```hcl
check "chalochalo_always_free_policy" {
  assert {
    condition = (
      local.compute_shape == "VM.Standard.A1.Flex" &&
      local.compute_ocpus == 2 &&
      local.compute_memory_gb == 12 &&
      local.mysql_shape == "MySQL.Free" &&
      local.mysql_storage_gb == 50
    )

    error_message = "Always Free policy violation."
  }
}
```

---

# 🔑 OCI Authentication

OCI Terraform authentication uses an API signing key.

Recommended location:

```text
~/.oci/
├── config
├── oci_api_key.pem
└── oci_api_key_public.pem
```

Terraform can reference the key from any project:

```hcl
private_key_path = pathexpand("~/.oci/oci_api_key.pem")
```

This means the `.pem` file does **not** need to be copied into every Terraform project.

---

# 🔐 Protect the OCI Private Key

Set restrictive permissions:

```bash
chmod 700 ~/.oci
chmod 600 ~/.oci/oci_api_key.pem
```

Never commit:

```text
*.pem
.oci/
terraform.tfvars
*.tfstate
*.tfstate.*
```

Recommended `.gitignore`:

```gitignore
*.pem
.oci/
terraform.tfvars
*.tfstate
*.tfstate.*
.terraform/
```

---

# 🔑 Key Recovery

OCI does not provide your private key back after it is lost.

Therefore:

```text
Mac
 │
 └── ~/.oci/oci_api_key.pem
              │
              ▼
       Secure encrypted backup
```

Keep an encrypted recovery copy separately.

OCI also supports multiple API signing keys, allowing a separate recovery/rotation key.

Do not store the private key in:

```text
❌ GitHub
❌ Source repository
❌ Public cloud storage
❌ Docker image
❌ README
```

---

# 🔑 SSH Access

OCI API authentication and VM SSH authentication are separate.

```text
OCI API Key
~/.oci/oci_api_key.pem
        │
        └── Terraform / OCI CLI
```

versus:

```text
SSH Key
~/.ssh/chalochalo_ed25519
        │
        └── SSH → ChaloChalo VM
```

Terraform receives the SSH **public** key:

```hcl
ssh_public_key = "ssh-ed25519 AAAA..."
```

Never place the SSH private key in Terraform source code.

---

# 🤖 Ollama

Ollama runs locally on the A1 VM.

Architecture:

```text
FastAPI
   │
   │ internal request
   ▼
Ollama
   │
   ▼
Local LLM
```

Benefits:

* No external AI API required
* No separate OCI AI service
* Application data can remain inside the infrastructure
* No separate AI API key

However, the A1 machine has only:

```text
2 OCPU
12 GB RAM
```

Therefore model size and concurrency must be selected carefully.

---

# 💻 Local Development

## Prerequisites

Install:

```text
Node.js
Python
MySQL client
Docker
Terraform
OCI CLI
Git
```

Verify:

```bash
node --version
python3 --version
docker --version
terraform version
oci --version
git --version
```

---

# 🐳 Docker Development

Build:

```bash
docker compose build
```

Start:

```bash
docker compose up -d
```

View logs:

```bash
docker compose logs -f
```

Stop:

```bash
docker compose down
```

---

# 🧪 Terraform Development

Initialize:

```bash
cd infrastructure/terraform

terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Generate plan:

```bash
terraform plan -out=tfplan
```

Inspect:

```bash
terraform show -no-color tfplan
```

Apply:

```bash
terraform apply "tfplan"
```

Destroy only when intentionally decommissioning:

```bash
terraform destroy
```

---

# 🌎 Environment Variables

Sensitive values should be supplied through environment variables.

Example:

```bash
export TF_VAR_mysql_admin_password='YOUR_STRONG_PASSWORD'
```

Verify that it exists without printing the password:

```bash
echo ${TF_VAR_mysql_admin_password:+MYSQL_PASSWORD_SET}
```

Expected:

```text
MYSQL_PASSWORD_SET
```

---

# 🚀 Deployment Flow

The recommended deployment flow is:

```text
Developer
    │
    ▼
Git Repository
    │
    ▼
Terraform
    │
    ▼
OCI Provider
    │
    ▼
VCN
    │
    ├── Public Subnet
    │       │
    │       └── A1 VM
    │             ├── Nginx
    │             ├── FastAPI
    │             └── Ollama
    │
    └── Private Subnet
            │
            └── MySQL
```

Application request:

```text
Browser
   │
   ▼
HTTPS
   │
   ▼
Nginx
   │
   ▼
FastAPI
   │
   ├──────────────► MySQL
   │
   └──────────────► Ollama
```

---

# 🔒 Security

Security principles:

### Database

MySQL must remain private.

```text
Internet
   X
   │
   X
MySQL
```

Only:

```text
Application subnet
       │
       │ TCP 3306
       ▼
     MySQL
```

### SSH

Initial bootstrap may allow SSH access, but production should restrict SSH to a trusted IP/network.

### Secrets

Never commit:

```text
OCI private key
MySQL password
SSH private key
Terraform state
API secrets
```

---

# 💵 Cost Protection

Before applying Terraform, always inspect:

```bash
terraform plan
```

Verify:

```text
VM.Standard.A1.Flex
2 OCPU
12 GB

MySQL.Free
50 GB
```

Also verify that the plan does **not** contain unexpected:

```text
Paid Compute
Paid MySQL
Load Balancer
NAT Gateway
Paid AI services
```

The project should additionally use OCI billing/usage monitoring as a second protection layer.

---

# 🩺 Troubleshooting

## OCI: Out of Capacity

Error:

```text
Out of capacity for shape VM.Standard.A1.Flex
```

Do not change:

```text
2 OCPU → 4 OCPU
12 GB → 24 GB
```

Instead:

```text
AD-1
 ↓
AD-2
 ↓
AD-3
 ↓
Wait
```

while remaining inside the home region and Always Free configuration.

---

## Terraform: Private Key Error

Error:

```text
can not create client,
bad configuration:
did not find a proper configuration for private key
```

Check:

```bash
ls -l ~/.oci/
```

Then:

```bash
chmod 600 ~/.oci/oci_api_key.pem
```

Verify the key exists:

```bash
head -n 1 ~/.oci/oci_api_key.pem
```

The provider must point to:

```hcl
private_key_path = pathexpand("~/.oci/oci_api_key.pem")
```

---

## Terraform Plan Asks for MySQL Password

Set:

```bash
export TF_VAR_mysql_admin_password='YOUR_STRONG_PASSWORD'
```

Then:

```bash
terraform plan
```

---

## Saved Terraform Plan Is Outdated

If you change:

```text
Availability Domain
Region
Shape
Terraform variables
```

do not reuse an old `tfplan`.

Create a new one:

```bash
rm -f tfplan

terraform plan -out=tfplan
```

Then:

```bash
terraform apply "tfplan"
```

---

# 🛡 Production Hardening

Before production, complete:

* Restrict SSH access
* HTTPS/TLS
* Strong authentication
* Authorization/RBAC
* API rate limiting
* Input validation
* Database backups
* Database migration strategy
* Audit logging
* Application logging
* Monitoring
* Health checks
* Error handling
* Secret rotation
* Terraform state protection
* OCI budget/usage monitoring
* Disaster recovery testing

---

# 🗺 Development Roadmap

## Phase 1 — Infrastructure

* [x] OCI account strategy
* [x] PAYG + Always Free policy
* [x] VCN
* [x] Public subnet
* [x] Private subnet
* [x] A1 compute
* [x] MySQL
* [x] Terraform
* [x] OCI authentication
* [ ] Capacity pre-flight automation

## Phase 2 — Backend

* [ ] FastAPI project
* [ ] Authentication
* [ ] User management
* [ ] Ride management
* [ ] Booking
* [ ] Wallet
* [ ] Notifications
* [ ] API documentation

## Phase 3 — Database

* [ ] MySQL schema
* [ ] Migration framework
* [ ] Indexes
* [ ] Foreign keys
* [ ] Transaction handling
* [ ] Backup/restore strategy

## Phase 4 — Frontend

* [ ] Landing page
* [ ] Login
* [ ] Registration
* [ ] Find Ride
* [ ] Publish Ride
* [ ] Ride Details
* [ ] Booking
* [ ] Wallet
* [ ] Profile
* [ ] Settings

## Phase 5 — AI

* [ ] Ollama
* [ ] Model selection
* [ ] AI assistant
* [ ] RAG
* [ ] Ride recommendations
* [ ] AI support assistant

## Phase 6 — Production

* [ ] HTTPS
* [ ] Monitoring
* [ ] Logging
* [ ] Security hardening
* [ ] Backup
* [ ] Disaster recovery
* [ ] Cost monitoring

---

# 📌 Important Project Rules

The following rules apply to the OCI deployment:

```text
1. PAYG account is allowed.
2. Always Free infrastructure is mandatory.
3. A1 must remain 2 OCPU / 12 GB.
4. MySQL must remain MySQL.Free / 50 GB.
5. MySQL remains private.
6. Never use paid resources as a capacity fallback.
7. Never commit private keys or passwords.
8. Review Terraform plan before every apply.
9. If A1 capacity is unavailable, try another home-region AD or wait.
10. Do not solve capacity problems by increasing the VM size.
```

---

# 📐 Final Architecture

```text
                         CHALOCHALO
                              │
                    ┌─────────┴─────────┐
                    │                   │
                 FRONTEND            OCI CLOUD
                    │                   │
                    ▼                   ▼
                 Nginx              VCN
                    │                   │
        ┌───────────┼───────────┐       │
        │           │           │       │
       Auth        User        Ride      │
        │           │           │       │
        └───────────┼───────────┘       │
                    │                   │
                Booking                 │
                    │                   │
             ┌──────┴──────┐            │
             │             │            │
          MySQL          Ollama         │
             │             │            │
             └─────────────┴────────────┘
```

## Infrastructure

```text
PAYG Account
     │
     ▼
Home Region
     │
     ▼
VCN 10.0.0.0/16
     │
     ├── Public Subnet 10.0.1.0/24
     │       │
     │       └── A1
     │           2 OCPU / 12 GB
     │
     └── Private Subnet 10.0.2.0/24
             │
             └── MySQL.Free
                 50 GB
```

## Cost Policy

```text
PAYG
 │
 └── Always Free resources
        │
        ├── A1 2 OCPU / 12 GB
        ├── MySQL.Free 50 GB
        └── Required networking
                 │
                 ▼
              ₹0 target
```

---

# 📄 License

Add the project's selected open-source/commercial license here before public distribution.

---

# 👨‍💻 Project Status

**Current stage:** Infrastructure foundation and architecture

**Cloud:** Oracle Cloud Infrastructure

**Infrastructure:** Terraform

**Compute:** OCI ARM64 A1

**Database:** OCI MySQL

**Backend:** FastAPI

**Frontend:** Responsive web application

**AI:** Ollama

**Deployment model:** Docker

**Cost strategy:** PAYG account with Always Free resource restriction
