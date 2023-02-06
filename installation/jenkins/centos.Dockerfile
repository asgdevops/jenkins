# Build base image
FROM centos:7 AS centos-base

LABEL maintainer="Antonio Salazar <antonio.salazar.devops@gmail.com>"

USER root

# Arguments
ARG username
ARG key

# Install sudo 
RUN yum install -y sudo 

# Set up user
RUN useradd -rm -d /home/$username -s /bin/bash -g root -G wheel -u 1000 $username && \
    echo $username:$username | chpasswd && \
    mkdir -p /home/$username/.ssh && \
    chmod 700 /home/$username/.ssh && \
    echo "$username  ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers 

# Copy ssh publick key
COPY $key.pub /home/$username/.ssh/authorized_keys

# Grant default user access to .ssh directory
RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Build from base
FROM centos-base AS centos-ssh

# Install SSHD
RUN yum install -y openssh-server 

# Configure SSHD
RUN mkdir /var/run/sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v

# install packages: git, and open JDK 11
RUN yum install -y git.x86_64 && \
    yum -y install java-11-openjdk java-11-openjdk-devel

# setup java 11
RUN JAVA=`alternatives --list | awk '{ print $3 }' | grep -E '/bin/java$'` && \
    alternatives --set java $JAVA

# Setd default username
USER $username
WORKDIR /home/$username

EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

# docker build . --build-arg key=jenkins_key --build-arg username=jenkins -f centos.Dockerfile -t centos/ssh:7