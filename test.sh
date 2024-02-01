sudo apt-get update 
#sudo apt-get install ufw

#sudo ufw allow OpenSSH

#sudo ufw allow 8080

#sudo ufw --force enable



sudo apt install fontconfig openjdk-17-jre -y

sudo apt install curl -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
	
sudo apt-get update

sudo apt install docker.io -y

sudo usermod -aG docker $USER

sudo chmod 666 /var/run/docker.sock

sudo apt install maven -y

sudo wget -c -O /tmp/gradle-7.6.3-all.zip https://services.gradle.org/distributions/gradle-7.6.3-all.zip


sudo unzip -d /opt/gradle /tmp/gradle-7.6.3-all.zip

sudo touch /etc/profile.d/gradle.sh


sudo tee -a /etc/profile.d/gradle.sh <<EOF
export GRADLE_HOME=/opt/gradle/gradle-7.6.3
export PATH=\${GRADLE_HOME}/bin:\${PATH}
EOF

sudo chmod +x /etc/profile.d/gradle.sh

source /etc/profile.d/gradle.sh

# sudo snap install gradle --classic

# export GRADLE_HOME=/snap/gradle/current/opt/gradle

sudo export JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64

sudo export PATH=$JAVA_HOME/bin:$PATH

# cd /home/





sudo apt install unzip



sudo apt install git-all -y

sudo systemctl enable docker

sudo systemctl start  docker

sudo systemctl status docker


sudo apt-get install jenkins -y

sudo cp /home/serv/jenkins.service /lib/systemd/system/jenkins.service

sudo systemctl daemon-reload

sudo systemctl restart jenkins
