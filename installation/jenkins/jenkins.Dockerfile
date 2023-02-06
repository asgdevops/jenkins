# Jenkins Dockerfile
FROM jenkins/jenkins:2.387-jdk11 AS jenkins-blueocean

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

USER jenkins

RUN jenkins-plugin-cli --plugins "blueocean:1.25.7 docker-workflow:1.29"
