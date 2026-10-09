# AWS Cloud Infrastructure & Automated Deployment (E-Commerce)

Production deployment pipeline for Node.js & PostgreSQL on AWS (ap-south-1) with custom VPC networking, systemd daemons, and immutable AMI releases.

## Architecture

- **VPC & Security**: Public subnet with IGW route `0.0.0.0/0`, Security Group allowing TCP 3000 and TCP 22.
- **Staging Instance**: Amazon Linux 2023 (t3.micro) running PostgreSQL 15 and Node.js 20 under systemd (`shop.service`).
- **Golden AMI**: Baked `shop-staging-ami` capturing validated app and database states.
- **Production Instance**: Launched from `shop-staging-ami` with zero-touch automated startup.

## Health Endpoints

Both instances return HTTP 200 OK:
\`\`\`json
{
  "status": "ok",
  "database": "connected"
}
\`\`\`
