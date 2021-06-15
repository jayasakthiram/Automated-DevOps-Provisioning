#!/bin/sh

#Installing Java for Jenkins
sudo apt update
sudo apt install openjdk-8-jdk openjdk-8-doc -y

#JFrog setup
sudo apt install wget software-properties-common
wget -qO - https://api.bintray.com/orgs/jfrog/keys/gpg/public.key | sudo  apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://jfrog.bintray.com/artifactory-debs $(lsb_release -cs) main"
sudo apt update
sudo apt install jfrog-artifactory-oss -y
sudo systemctl start artifactory.service
sudo systemctl enable artifactory.service


#Gitlab Installation
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates tzdata
sudo echo "postfix postfix/mailname string dnacto.com" | sudo debconf-set-selections
sudo echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
sudo apt-get install -y postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee -y

#Gitlab HTTPS setup
varip=$(curl icanhazip.com)
sudo sed -i -e "s|http://gitlab.example.com|https://$varip|g" /etc/gitlab/gitlab.rb
sudo sed -i -e '$anginx["enable"] = true\nnginx["redirect_http_to_https"] = true\nregistry_nginx["redirect_http_to_https"] = true\nmattermost_nginx["redirect_http_to_https"] = true\nletsencrypt["contact_emails"] = ["foo@email.com"]' /etc/gitlab/gitlab.rb

sudo gitlab-ctl reconfigure


#Installing Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y
sudo service jenkins restart

sleep 30

#Jenkins HTTPS setup
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export JENKINS_HOME=/var/lib/jenkins/

sudo mkdir $JENKINS_HOME/.keystore
sudo chown -R jenkins: $JENKINS_HOME/.keystore
cd $JENKINS_HOME/.keystore

sudo sed -i -e '$a[ subject_alt_name ]\nsubjectAltName = DNS:localhost' /etc/ssl/openssl.cnf

sudo openssl req -x509 -nodes -newkey rsa:2048 -config /etc/ssl/openssl.cnf -extensions subject_alt_name -keyout private.key -out self_signed.pem -subj '/C=NG/ST=Lagos/L=Victoria_Island/O=Your_Organization/OU=Your_department/CN=www.yourdomain.com/emailAddress=youremail@yourdomain.com' -days 1000

sudo openssl x509 -in self_signed.pem -text -noout

sudo openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -export -in self_signed.pem -inkey private.key -name myalias -out jkeystore.p12  -passout 'pass:example@123'

sudo keytool -importkeystore -destkeystore jkeystore.jks -deststoretype PKCS12 -deststorepass example@123 -srcstoretype PKCS12 -srckeystore jkeystore.p12 -srcstorepass example@123

sudo keytool -list -v -keystore jkeystore.jks -storepass example@123

sudo keytool -export -keystore jkeystore.jks -alias myalias -file self-signed.crt -storepass example@123

sudo keytool -importcert -file self-signed.crt -alias myalias -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -trustcacerts -noprompt

sudo service jenkins stop

sudo sed -i "s/HTTP_PORT=8080/HTTP_PORT=-1/g" /etc/default/jenkins

sudo sed -i "s/^JENKINS_ARGS=*/#JENKINS_ARGS=/g" /etc/default/jenkins

sudo sed -i -e '$aJAVA_ARGS=\"Djavax.net.ssl.trustStore=$JAVA_HOME\/jre\/lib\/security\/cacerts -Djavax.net.ssl.trustStorePassword=changeit\"\nJAVA_ARGS=\"-Xmx2048m -Djava.awt.headless=true\"\nJENKINS_ARGS=\"--webroot=\/var\/cache\/$NAME\/war --httpPort=$HTTP_PORT --httpsPort=8443 --httpsKeyStore=$JENKINS_HOME\/.keystore\/jkeystore.jks --httpsKeyStorePassword=example@123\"' /etc/default/jenkins

sudo service jenkins restart

sleep 30 

#JFrog setup
#sudo apt install wget software-properties-common
#wget -qO - https://api.bintray.com/orgs/jfrog/keys/gpg/public.key | sudo  apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://jfrog.bintray.com/artifactory-debs $(lsb_release -cs) main"
#sudo apt update
#sudo apt install jfrog-artifactory-oss -y
#sudo systemctl start artifactory.service
#sudo systemctl enable artifactory.service

#Jenkins Inital Password display on console
echo " $(tput setab 3)$(tput setaf 0)Jenkins - InitialPassword:-$(tput sgr 0)" " $(tput setaf 2)$(tput smso)$(tput setab 0)$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)$(tput sgr 0)"

