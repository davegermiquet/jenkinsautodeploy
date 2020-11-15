#!/bin/bash

# Installs ansible prequisites jenkins and developer utilities for the application build environment
# Create DOCKER FILE

export JENKINS_DOWNLOAD_MIRROR_TO_USE=http://mirrors.jenkins-ci.org/
export DEBOS_CMD=docker
COOKIE_PATH=/tmp/cookie_jenkins_crumb.txt

# https://support.cloudbees.com/hc/en-us/articles/219257077-CSRF-Protection-Explained
# https://wiki.jenkins.io/display/JENKINS/Remote+access+API#RemoteaccessAPI-CSRFProtection
# but a bit adjusted as it is not exactly usable as it is in the documentation page.
# We discovered that the CRUMB should be identical because it
# is paired with a cookie. Thus save the cookie, it is important.

# configures the Default Plugins to install

cat << END > pluginstoinstall.txt
blueocean:1.24.3 
workflow-multibranch
build-timeout:latest 
configuration-as-code:latest
credentials-binding:latest 
git:latest 
github-branch-source:latest 
pipeline-github-lib:latest 
pipeline-stage-view:latest 
timestamper:latest 
workflow-aggregator:latest 
ws-cleanup:latest 
file-operations:latest 
job-import-plugin
terraform
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
RUN apt-get update && apt-get install -y docker-ce-cli terraform wget ansible rsync git python3-pip python3-dev python3 curl apt-utils  software-properties-common golang net-tools dnsmasq postgresql-client openssh-server 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN rm -rf /var/jenkins_home/.ssh
USER jenkins
VOLUME /var/jenkins_home/workspace
RUN echo y |  ssh-keygen -N "" -b 4028 -f /var/jenkins_home/.ssh/id_rsa
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
$DEBOS_CMD exec jenkinsofficialinstaller sh -c "cd /tmp;JENKINS_UC_DOWNLOAD=${JENKINS_DOWNLOAD_MIRROR_TO_USE}  jenkins-plugin-cli --plugin-file  pluginstoinstall.txt"
$DEBOS_CMD exec jenkinsofficialinstaller ansible-galaxy collection install community.kubernetes
$DEBOS_CMD restart jenkinsofficialinstaller

echo "90 seconds for the system to restart and complete"
# import the config (crumb is important)
sleep 90
export COOKIEJAR="$(mktemp)"
export CRUMB=$(curl  --cookie-jar "$COOKIEJAR" "http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
curl -X POST --cookie "$COOKIEJAR" -H "$CRUMB" http://localhost:8080/createItem\?name=QLedger  --data-binary @qledgerconfig.xml -H "Content-Type:application/xml"
