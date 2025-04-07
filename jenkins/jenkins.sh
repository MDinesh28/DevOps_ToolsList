# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install Git
sudo apt install -y git

# Install Java 17 (JDK version for full functionality with Jenkins)
sudo apt install -y openjdk-17-jdk

# Add Jenkins repository key and source
wget -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update again to include Jenkins repo
sudo apt update -y

# Install Jenkins
sudo apt install -y jenkins

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Check Jenkins service status
sudo systemctl status jenkins
