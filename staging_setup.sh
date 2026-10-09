#!/bin/bash
exec > /var/log/user-data.log 2>&1

# 1. System packages & dependencies
dnf update -y
dnf install -y git docker postgresql15 postgresql15-server
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
systemctl enable --now docker
usermod -aG docker ec2-user

# 2. PostgreSQL 15 configuration
postgresql-setup --initdb
sed -i 's/ident/scram-sha-256/g' /var/lib/pgsql/data/pg_hba.conf
systemctl enable --now postgresql
sudo -u postgres psql -c "CREATE USER appuser WITH PASSWORD 'ChangeMe123' CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE shop OWNER appuser;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE shop TO appuser;" 2>/dev/null || true

# 3. Application setup
cd /home/ec2-user
git clone https://github.com/meysamraza/E-com-site.git app
cd /home/ec2-user/app
npm install

cat > /home/ec2-user/app/.env <<'ENVEOF'
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=shop
DB_USER=appuser
DB_PASSWORD=ChangeMe123
JWT_SECRET=change_this_secret
ENVEOF

npm run db:init || true
chown -R ec2-user:ec2-user /home/ec2-user/app

# 4. Systemd daemon configuration
cat > /etc/systemd/system/shop.service <<'SVCEOF'
[Unit]
Description=Shop app
After=network.target postgresql.service
[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/node server.js
Restart=always
[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable --now shop
