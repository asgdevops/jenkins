# Build base image
FROM debian:11-slim AS debian-base
USER root

# Disable interactive mode
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Arguments
ARG username
ARG key

# Install sudo 
RUN apt update -y && apt install -y sudo 

# Set up devops user
RUN useradd -rm -d /home/$username -s /bin/bash -g root -G sudo -u 1000 $username && \
    echo $username:$username | chpasswd && \
    mkdir -p /home/$username/.ssh && \
    chmod 700 /home/$username/.ssh && \
    echo "$username    ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers 

COPY $key.pub /home/$username/.ssh/authorized_keys

RUN chown $(id -u $username):$(id -g $username) -R /home/$username/.ssh && \
    chmod 600 /home/$username/.ssh/authorized_keys

# Build from base
FROM debian-base AS debian-ssh

# Install SSHD
RUN sudo apt update -y && sudo apt install -y openssh-server 

# Configure SSHD
RUN  mkdir /var/run/sshd
ADD ./sshd_config /etc/ssh/sshd_config
RUN ssh-keygen -A -v

# Switch to default user
USER $username
WORKDIR /home/$username

EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

#...
# docker build . --build-arg key=remote-key --build-arg username=debian -f debian.Dockerfile -t debian/ssh:11