# Automated Provisioning of DevOps Tools
This script helps you to provision DevOps native services like Jenkins, GitLab and Jfrog artifactory in a single setup.

## Note
- This is a shell script executed and tested in Ubuntu latest version only.
- Jenkins service is created with HTTPS enabled.
    - Automatically secret keys and cert files are generated and used for HTTPS authorization.
- GitLab service is also created with HTTPS enabled.
    - GitLab HTTPS setup uses nginx module
- Java OpenJDK is also getting installed for Jenkins service
## Workflow Diagram
![Design View](https://github.com/mynameisjai/Automated-DevOps-Provisioning/blob/main/DevOps.png?raw=true)


### Output URL to look for
- **Jenkins** <br>
    - <VM_Ip address>:8443/<br>
Administrator Password will be displayed at the end in console log output.

- **GitLab** <br>
    - https://<VM_Ip address>/ <br>
    Just hit the public IP address secured with **https://** of the VM you hosted and it will redirect to the GitLab service
- **JFrog Artifactory** <br>
    - <VM_Ip address>:8082/artifactory
    Once the initial artifactory setup is done login with default credentials. <br> 
        - **Username:** admin <br>
        - **Password:** password

---
- Author : Jayasakthiram N <br>
- Input File: DevOps_setup.sh <br>
- Date Modified: 15th June 2021 
---
