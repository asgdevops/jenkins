# Build base image
FROM ubuntu:22.04 AS ubuntu-base

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

USER root

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Arguments username and SSH key
ARG username
ARG key

# Install sudo
RUN apt update -y && apt install -y sudo

# Set up user with sudo privileges
RUN useradd -rm -d /home/$username -s /bin/bash -g root -G sudo -u 1000 $username && \
    echo $username:$username | chpasswd && \
    mkdir -p /home/$username/.ssh && \
    chmod 700 /home/$username/.ssh && \
    echo "$username  ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers 

# Set up the SSH key
COPY $key.pub /home/$username/.ssh/authorized_keys

# Grant privileges to default user on ~/.ssh directory
RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Build from base
FROM ubuntu-base AS ubuntu-ssh

# Install SSHD
RUN apt update -y && apt install -y openssh-server 

# Configure SSHD.
RUN mkdir /var/run/sshd
ADD sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v

# install packages: git, and java
RUN apt install -y git && \
    apt install -y openjdk-11-jdk 

# Cleanup old packages
RUN apt -y autoremove 

# Switch to default user
USER $username
WORKDIR /home/$username

EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=jenkins_key --build-arg username=jenkins -f ubuntu.Dockerfile -t ubuntu/ssh:22.04
