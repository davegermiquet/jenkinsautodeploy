FROM jenkins/jenkins:latest
USER root
RUN usermod -G root jenkins
RUN apt-get update && apt-get install -y apt-transport-https \
ca-certificates curl gnupg2 \
software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg |  apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com stretch main"
RUN apt-get update && apt-get install -y docker-ce-cli terraform wget ansible rsync git python3-pip python3-dev python3 curl apt-utils  software-properties-common golang net-tools dnsmasq postgresql-client openssh-server 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf /var/jenkins_home/.ssh
USER jenkins
COPY ./files/pluginstoinstall.txt /tmp/pluginstoinstall.txt
VOLUME /var/jenkins_home/workspace
RUN echo y |  ssh-keygen -N "" -b 4028 -f /var/jenkins_home/.ssh/id_rsa
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_PORT="8080"
ENV JENKINS_HTTPS_PORT="-1"
ENV JENKINS_DOWNLOAD_MIRROR_TO_USE="http://mirrors.jenkins-ci.org/"
RUN sh -c "cd /tmp;JENKINS_UC_DOWNLOAD=${JENKINS_DOWNLOAD_MIRROR_TO_USE}  jenkins-plugin-cli --plugin-file  /tmp/pluginstoinstall.txt"