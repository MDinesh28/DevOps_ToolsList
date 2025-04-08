#!/bin/bash

# Exit on any error
set -e

# Update system and install Java 11
sudo apt update
sudo apt install -y openjdk-11-jdk wget

# Create dedicated nexus user (no login shell, no home directory)
sudo useradd -r -M -d /opt/nexus -s /usr/sbin/nologin nexus

# Create Nexus and Sonatype directories
sudo mkdir -p /opt/nexus /opt/sonatype-work
cd /opt/nexus

# Download and extract Nexus
wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz -O nexus.tar.gz
tar -xvzf nexus.tar.gz
sudo mv nexus-3.79.0-09 nexus
sudo rm nexus.tar.gz

# Set permissions
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work
sudo chmod -R 755 /opt/nexus /opt/sonatype-work

# Set run_as_user in nexus.rc
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/nexus/bin/nexus.rc

# Create systemd service file for Nexus
cat <<EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/nexus/bin/nexus start
ExecStop=/opt/nexus/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Nexus
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# (Optional) Allow Nexus port through firewall (if UFW is enabled)
if command -v ufw &> /dev/null; then
  sudo ufw allow 8081/tcp
fi

# (Optional) Create a symlink for easier Nexus CLI access
sudo ln -sf /opt/nexus/nexus/bin/nexus /usr/bin/nexus

# Show Nexus status and initial admin password
sudo systemctl status nexus
echo "Initial Admin Password:"
cat /opt/nexus/sonatype-work/nexus3/admin.password
