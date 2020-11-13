FROM jenkins/jenkins:latest
USER root
RUN usermod -G root jenkins
RUN apt-get update && apt-get install -y apt-transport-https        ca-certificates curl gnupg2        software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg |  apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository        "deb [arch=amd64] https://download.docker.com/linux/debian        $(lsb_release -cs) stable"
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get update && apt-get install -y docker-ce-cli terraform wget ansible rsync git python3-pip python3-dev python3 curl apt-utils  software-properties-common golang net-tools dnsmasq
USER jenkins
VOLUME /var/jenkins_home/workspace
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_PORT="8080"
ENV JENKINS_HTTPS_PORT="-1"
