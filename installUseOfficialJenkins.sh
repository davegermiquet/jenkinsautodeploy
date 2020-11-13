#!/bin/bash

# Installs ansible prequisites jenkins and developer utilities for the application build environment
# Create DOCKER FILE

export DEBOS_CMD=docker

# configures the Default Plugins to install

cat << END > pluginstoinstall.txt
ant:latest 
antisamy-markup-formatter:latest 
build-timeout:latest 
cloudbees-folder:latest
configuration-as-code:latest
credentials-binding:latest 
email-ext:latest 
git:latest 
github-branch-source:latest 
gradle:latest 
ldap:latest 
mailer:latest  
matrix-auth:latest  
pam-auth:latest 
pipeline-github-lib:latest 
pipeline-stage-view:latest 
ssh-slaves:latest 
timestamper:latest 
workflow-aggregator:latest 
ws-cleanup:latest 
file-operations:latest 
END

# Custmize Docker file for image

cat << EOF > Dockerfile
FROM jenkins/jenkins:latest
USER root
RUN usermod -G root jenkins
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg |  apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       \$(lsb_release -cs) stable"
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
RUN apt-get update && apt-get install -y docker-ce-cli terraform wget ansible rsync git python3-pip python3-dev python3 curl apt-utils  software-properties-common golang net-tools dnsmasq
USER jenkins
VOLUME /var/jenkins_home/workspace
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_PORT="8080"
ENV JENKINS_HTTPS_PORT="-1"
EOF

# build DOCKER IMAGE

$DEBOS_CMD build -t myjenkins-blueocean:1.1 .

# If there is no workspace folder, its not configured

[ ! -d "./workspace" ] && echo "please set up a folder in /workspace for volume disk" && exit 0

# Create network and configuration environment

$DEBOS_CMD network create jenkins
$DEBOS_CMD volume create --opt type=exfat --opt device=$PWD/workspace --opt o=bind --opt type=none  build-folder


# Run the image and docker in a docker setup

ARGS="run -p 0.0.0.0:8080:8080 -p 50000:50000 --name jenkinsofficialinstaller --network jenkins  --mount source=build-folder,target=/var/jenkins_home/workspace,volume-opt=o=uid=1000 -dit myjenkins-blueocean:1.1 /usr/local/bin/jenkins.sh"
$DEBOS_CMD $ARGS || docker start jenkinsofficialinstaller
$DEBOS_CMD run --name jenkins-docker  --rm  --detach  --privileged  -e DOCKER_TLS_CERTDIR=""  --network jenkins  --network-alias docker  --volume build-folder:/var/jenkins_home/workspace  --publish 2373:2375 docker:dind

# Import Default Plugins 
# This is also done becasue it sometimes times out in install

$DEBOS_CMD cp pluginstoinstall.txt  jenkinsofficialinstaller:/tmp/pluginstoinstall.txt
$DEBOS_CMD exec jenkinsofficialinstaller jenkins-plugin-cli --plugin-file /tmp/pluginstoinstall.txt

sleep 10
