# Build base image
FROM alpine:3.17 AS alpine-base

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

USER root

# Arguments
ARG username
ARG key

# Install sudo 
RUN apk update && apk add sudo 

# Set up user
RUN adduser $username -D -G wheel &&\
    echo "$username:$username" | chpasswd &&\
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# copy the SSH keys
COPY $key.pub /home/$username/.ssh/authorized_keys

RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Install ssh server
RUN apk add --no-cache openssh

# Configure SSHD
RUN mkdir /var/run/sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v

# Install git
RUN apk add git

# Install JDK 11
RUN apk add openjdk11

# Install ansible
RUN apk update && apk add ansible

# Install terraform
RUN apk add terraform --repository=https://dl-cdn.alpinelinux.org/alpine/v3.17/main

USER $username
WORKDIR /home/$username

EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=jenkins_key --build-arg username=jenkins -f alpine.Dockerfile -t alpine/ssh:3.17