# :information_source: Installing Jenkins on macOS

# :paw_prints: Steps 
1. Install the latest LTS version: 
```
brew install jenkins-lts
```

2. Start the Jenkins service:
```
brew services restart jenkins-lts
```

3. Update the Jenkins version: 
```
brew upgrade jenkins-lts
```

4. After starting the Jenkins service, browse to http://localhost:8080 and follow the instructions to complete the installation. 

# :wrench: Configure Jenkins after installation
- Follow the steps set up [Configure Jenkins after installation](jenkins_install_config.md) document.

  
# :books: References
- :link: [Installing Jenkins on macOS](hhttps://www.jenkins.io/doc/book/installing/macos/#macos)
- :link: [macOS Installers for Jenkins LTS](https://www.jenkins.io/download/lts/macos/#macos-installers-for-jenkins-lts)
