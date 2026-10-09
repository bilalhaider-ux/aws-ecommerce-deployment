# DevOps Mentorship - Assignment 1: DR Budget & AWS Deployment

This repository contains my submission and notes for Assignment 1 of the DevOps Mentorship Program (Phase 2) by mentor Meysam Raza.

The assignment has two parts:
1. **Part A:** Cost estimation for a Disaster Recovery (DR) setup in AWS Singapore (`ap-southeast-1`).
2. **Part B:** Building and deploying an e-commerce web application in AWS Mumbai (`ap-south-1`) with a custom VPC, staging environment, golden AMI, and production release.

---

## Part A: DR Region Budget (Singapore)

Estimated monthly costs using the AWS Pricing Calculator for `ap-southeast-1`:

- **EC2:** 1x `t3.micro` (Linux, 730 hrs)
- **EBS:** 30 GB `gp3` storage
- **Application Load Balancer:** 1 ALB (0.1 GB/hr, 5 req/s)
- **NAT Gateway:** 1 NAT Gateway (730 hrs, 20 GB data processed)
- **RDS PostgreSQL:** `db.t4g.micro`, Multi-AZ, 20 GB storage, 20 GB backup
- **AWS WAF:** 1 Web ACL with 3 rules (1M requests/month)
- **Data Transfer:** 50 GB outbound to internet

**Total Monthly Estimate:** **$124.50**  
The full estimation PDF is included in this repository: [`DR_Region_Budget_Singapore.pdf`](./DR_Region_Budget_Singapore.pdf).

---

## Part B: Main Region Deployment (Mumbai)

Upstream application repository: [meysamraza/E-com-site](https://github.com/meysamraza/E-com-site)

### Implementation Steps

1. **VPC Networking:**
   - Created a custom VPC with a public subnet in `ap-south-1`.
   - Attached an Internet Gateway (IGW) and configured the route table (`0.0.0.0/0` -> IGW).
   - Configured Security Group:
     - `TCP 3000` from `0.0.0.0/0` (Web app)
     - `TCP 22` restricted to my IP (SSH management)

2. **Staging Setup (`staging`):**
   - Launched an Amazon Linux 2023 `t3.micro` instance.
   - Installed Node.js 20, Docker, and PostgreSQL 15.
   - Configured PostgreSQL authentication, initialized the database schema (`npm run db:init`), and created a systemd service (`shop.service`) so the app runs automatically in the background.

3. **Golden AMI (`shop-staging-ami`):**
   - Created a custom image from the running, verified staging instance.
   - Waited until the AMI state reached `Available`.

4. **Production Deployment (`prod`):**
   - Launched a production instance from `shop-staging-ami` in the same VPC and subnet.
   - Verified that the application and PostgreSQL database booted automatically without running any manual setup commands.

---

## Live Endpoints & Health Check

Both instances are running and return `{"status":"ok","database":"connected"}`:

- **Staging URL:** http://3.109.186.53:3000
- **Staging Health:** http://3.109.186.53:3000/health
- **Production URL:** http://43.205.240.72:3000
- **Production Health:** http://43.205.240.72:3000/health

---

## Repository Files

- `staging_setup.sh`: Automated bootstrap script for Amazon Linux 2023.
- `DR_Region_Budget_Singapore.pdf`: Exported AWS Pricing Calculator report for Part A.
- `README.md`: Architecture and assignment walkthrough.
