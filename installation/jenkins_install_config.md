# :notes: Configure Jenkins after installation
## :paw_prints: Steps

1. Take the Initial Admin Password  from the `/var/jenkins_home/secrets/initialAdminPassword` file.
    
    ```bash
    cat /var/jenkins_home/secrets/initialAdminPassword
    ```
    
    ![01](images/jenkins_installation_01.png)
    
2. Open a browser to `http://localhost:${port}` address.
3. Input the Initial Admin Password and click on **Continue**.
    
    ![02](images/jenkins_installation_02.png)
    
4. Click on the **Install suggested plugins.**
    
    ![03](images/jenkins_installation_03.png)
    
5. The installation process will start and take some time to complete.
    
    ![04](images/jenkins_installation_04.png)
    
6. Provide the **Admin** **username**, **password**, **full name**, and **email** data. 
    
    ![05](images/jenkins_installation_05.png)
    
7. Setup the Jenkins URL address.
    
    ![06](images/jenkins_installation_06.png)
    
8. The **Jenkins is Ready!** confirmation screen is displayed. Proceed to start using Jenkins.
    
    ![07](images/jenkins_installation_07.png)
    
9. After the **Welcome to Jenkins!** page is shown.
    
    ![08](images/jenkins_installation_08.png)

# :books: References

- [Installing Jenkins official documentation.](https://www.jenkins.io/doc/book/installing)
- [Jenkins installation notes](README.md).