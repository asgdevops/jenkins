# :information_source: Installing Jenkins on Windows


Download the :link: [Jenkins Installer for Windows](https://www.jenkins.io/download/thank-you-downloading-windows-installer/)

Alternatively download the [jenkins.msi](https://get.jenkins.io/windows/2.364/jenkins.msi) file.


# Installation steps using Windows MSI installer
- **Step 1**: Setup wizard
On opening the Windows Installer, an Installation Setup Wizard appears, Click Next on the Setup Wizard to start your installation.

Windows Installation Setup Wizard

- **Step 2**: Select destination folder
Select the destination folder to store your Jenkins Installation and click Next to continue.

Jenkins Installation Destination

- **Step 3**: Service logon credentials
When Installing Jenkins, it is recommended to install and run Jenkins as an independent windows service using a local or domain user as it is much safer than running Jenkins using LocalSystem(Windows equivalent of root) which will grant Jenkins full access to your machine and services.

To run Jenkins service using a local or domain user, specify the domain user name and password with which you want to run Jenkins, click on Test Credentials to test your domain credentials and click on Next.

Jenkins Service Logon Credentials

If you get Invalid Logon Error pop-up while trying to test your credentials, follow the steps explained here to resolve it.

- **Step 4**: Port selection
Specify the port on which Jenkins will be running, Test Port button to validate whether the specified port if free on your machine or not. Consequently, if the port is free, it will show a green tick mark as shown below, then click on Next.

Jenkins Select Port

- **Step 5**: Select Java home directory
The installation process checks for Java on your machine and prefills the dialog with the Java home directory. If the needed Java version is not installed on your machine, you will be prompted to install it.

Once your Java home directory has been selected, click on Next to continue.

Select Java Home Directory

- **Step 6**: Custom setup
Select other services that need to be installed with Jenkins and click on Next.

Jenkins Custom Setup

- **Step 7**: Install Jenkins
Click on the Install button to start the installation of Jenkins.

Windows Install Jenkins

Additionally, clicking on the Install button will show the progress bar of installation, as shown below:

Windows Installation Progress

- **Step 8**: Finish Jenkins installation
Once the installation completes, click on Finish to complete the installation.

Jenkins will be installed as a Windows Service. You can validate this by browsing the services section, as shown below:

Windows Jenkins Service

See the upgrade steps when you upgrade to a new release.
Post-installation setup wizard
After downloading, installing and running Jenkins, the post-installation setup wizard begins.

This setup wizard takes you through a few quick "one-off" steps to unlock Jenkins, customize it with plugins and create the first administrator user through which you can continue accessing Jenkins.

## Unlocking Jenkins
When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.

**Step 1**
Browse to http://localhost:8080 (or whichever port you configured for Jenkins when installing it) and wait until the Unlock Jenkins page appears.

Unlock Jenkins page

**Step 2**
The initial Administrator password should be found under the Jenkins installation path (set at Step 2 in Jenkins Installation).

For default installation location to C:\Program Files\Jenkins, a file called initialAdminPassword can be found under C:\Program Files\Jenkins\secrets.

However, If a custom path for Jenkins installation was selected, then you should check that location for initialAdminPassword file.

Jenkins Initial Password Location

**Step 3**
Open the highlighted file and copy the content of the initialAdminPassword file.

Jenkins Initial Password File

**Step 4**
On the Unlock Jenkins page, paste this password into the Administrator password field and click Continue.
Notes:

You can also access Jenkins logs in the jenkins.err.log file in your Jenkins directory specified during the installation.

The Jenkins log file is another location (in the Jenkins home directory) where the initial password can also be obtained. Windows Jenkins Log File This password must be entered in the setup wizard on new Jenkins installations before you can access Jenkins’s main UI. This password also serves as the default administrator account’s password (with username "admin") if you happen to skip the subsequent user-creation step in the setup wizard.

# :books: References
- :link: [Installing Jenkins on Windows](https://www.jenkins.io/doc/book/installing/windows/#windows)
