#!/bin/bash

# Update & install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-17-jdk unzip wget -y

# Verify Java
java -version

# Create SonarQube user
sudo adduser --system --no-create-home --group --disabled-login sonarqube

# Download and set up SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip
sudo unzip sonarqube-10.3.0.82913.zip
sudo mv sonarqube-10.3.0.82913 sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Create SonarQube systemd service
sudo bash -c 'cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and start SonarQube
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# Show status
sudo systemctl status sonarqube
