# Jenkins Dockerfile
FROM jenkins/jenkins:2.346.3-jdk11 AS blueocean

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update && \
    apt-get install -y lsb-release 

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && \
    apt-get install -y docker-ce-cli

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.7 docker-workflow:1.29"

# Build new image
FROM blueocean AS jenkins-blueocean

USER root

# Install Maven
RUN apt update -y && \
    apt install -y wget && \
    apt install -y maven
