# Jenkins Dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Maven
RUN apt update -y && \
    apt install -y wget && \
    apt install -y maven
