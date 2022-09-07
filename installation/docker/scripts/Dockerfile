# Jenkins Dockerfile
FROM jenkins/jenkins:lts

# Set-up the docker file variables
ARG alias=docker
ARG cert_vol=/certs/client
ARG data_vol=/var/jenkins_home
ARG network=jnet
ARG port=8082
ARG storage=/app/data/storage/cicd2

# Set the environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JENKINS_HOME="${data_vol}"

USER root

# Create the local storage directory if not exists
RUN mkdir -p ${storage}

# Install OS utilities
RUN apt-get update && apt-get install -y apt-utils curl

EXPOSE ${port} 50000

VOLUME ["${cert_vol}","${data_vol}"]
