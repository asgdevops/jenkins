# :information_source: Installing Jenkins on Linux

# Debian/Ubuntu

- Install the Jenkins Key on the system.
```
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

- Download the package repository.
```
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
```

- Install Java Runtime Environment.
```
sudo apt update
sudo apt install openjdk-11-jre
java -version
```

- Install Jenkins through apt package manager.
```
sudo apt-get update
sudo apt-get install fontconfig openjdk-11-jre
sudo apt-get install jenkins
```

# Fedora
- Install Java.
```
sudo dnf upgrade
sudo dnf install java-11-openjdk
```

- Download the Jenkins repository.
```
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
```

- Install the Jenkins Key onto the system.
```
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

- Install Jenkins with dnf package manager.
```
sudo dnf install jenkins
sudo systemctl daemon-reload
```

# Red Hat/CentOS

- Install Java JDK 11.
```
sudo yum upgrade && sudo yum install java-11-openjdk ;
```

- Download the Jenkins repository.
```
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo 
```

- Install the Jenkins Key onto the system.
```
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

- Install Jenkins with yum package manager.

```
sudo yum upgrade && sudo yum install jenkins ;
sudo systemctl daemon-reload ;
```

# :wrench: Configure Jenkins after installation
- Follow the steps set up [Configure Jenkins after installation](jenkins_install_config.md) document.

# :arrow_up: Starting, :arrow_down: Stopping, and :arrows_clockwise: Restarting Jenkins

## Enable the Jenkins service to start at boot using the command:
```
sudo systemctl enable jenkins
```

## Disable Jenkins service from boot
```
sudo systemctl disable jenkins.service 
chkconfig --del jenkins
```

## :arrow_up: Start Jenkins
```
sudo systemctl start jenkins
```

## :arrow_down: Stop Jenkins
```
sudo systemctl stop jenkins 
```

## :arrows_clockwise: Restart Jenkins
```
sudo systemctl restart jenkins 
```

## :white_check_mark: Verify the status
```
sudo systemctl status jenkins
```

# :books: References
- :link: [Installing Jenkins on Debian/Ubuntu](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)
- :link: [Installing Jenkins on Fedora](https://www.jenkins.io/doc/book/installing/linux/#fedora)
- :link: [Installing Jenkins on Red Hat/CentOS](https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos)
- :link: [Jenkins Debian Packages](https://pkg.jenkins.io/debian-stable/)   
- :link: [Managing systemd services](https://www.jenkins.io/doc/book/system-administration/systemd-services/)
- :link: [Starting, stopping, and restarting Jenkins on Ubuntu](https://learning.oreilly.com/library/view/learning-continuous-integration/9781788479356/b82c23b3-5394-499d-a3f4-44f9da9ee6b9.xhtml)
