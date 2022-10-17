#!/bin/bash
# Name:         jenkins_create.sh
# Description:  Create a Jenkins container with blueocean plugin and four agents
# Usage:        $PWD/jenkins_create.sh [ options ] 
# Options:      
#               '-a' | '--agent-port':  Jenkins agent port         (default 50000)
#               '-c' | '--container':   Container Name             (default 'jenkins')
#               '-i' | '--instance':    Jenkins instance number    (default 0)
#               '-p' | '--http-port':   Jenkins http port number   (default 8080)
#               '-w' | '--work-dir':    Jenkins Working directory  (default /app/data)
#               * default values are assigned when no options are provided.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# | Log        | Who                                             | What |
# | :--        | :--                                             | :--  |
# | 2022-10-15 | antonio.salazar.devops@gmail.com                | Initial creation. |
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#
# show usage
#
show_usage() {
  echo -e "\nUsage:\n
  ./$(basename ${0}) { <option1> <value1> .. <option..n> <value..n> } \n
Options:\n
  '-a' | '--agent-port':  Jenkins agent port         (default 50000) \n
  '-c' | '--container':   Container Name             (default 'jenkins') \n
  '-i' | '--instance':    Jenkins instance number    (default 0) \n
  '-p' | '--http-port':   Jenkins http port number   (default 8080) \n
  '-w' | '--work-dir':    Jenkins Working directory  (default /app/data) \n
  * default values are assigned when no options are provided. \n
\n
Example:\n
  ./$(basename ${0}) --app-name jenkins \n"
}

set_default_values() {
  # application group number
  instance_number=0; 

  # application name
  container=jenkins;

  # application port
  http_port=8080

  # agent port
  agent_port=50000

  # Application working directory
  work_dir=/app/data;
}


#
# Create the env variables file
#
set_env() {

  echo "Set environment variables";

  # if instance number is setup
  if [ -z "${instance_number##[1-9]*}" ] ; then
    container=${container}${instance_number};
    http_port=$(( $http_port + $instance_number ))
    agent_port=$(( $agent_port + $instance_number ))
  fi

  # Jenkins base
  base=${work_dir}/${container};

  # Jenkins certs
  cert=${base}/${container}-cert;

  # Jenkins data
  data=${base}/${container}-data;

  # Jenkins centos
  centos=${base}/${container}-centos;
  
  # Jenkins debian
  debian=${base}/${container}-debian;
  
  # Jenkins ubuntu
  ubuntu=${base}/${container}-ubuntu;

  # application context
  context=${base}

  # jenkins http port
  http_port=${http_port};

  # jenkins agent port
  agent_port=${agent_port};

  # docker container network alias
  alias=docker;

  # docker engine port
  docker_port=2375;

  # docker network name   
  network=${container}_net;

  # volume cert alias
  volume_cert=${container}-cert;

  # volume data alias
  volume_data=${container}-data;

  # volume centos alias
  volume_centos=${container}-centos;

  # volume debian alias
  volume_debian=${container}-debian;

  # volume ubuntu alias
  volume_ubuntu=${container}-ubuntu;

  # Container Environment Variables 
  # docker certificates
  DOCKER_TLS_CERTDIR=/certs
  DOCKER_HOST=tcp://docker:${docker_port} 
  DOCKER_CERT_PATH=/certs/client 
  DOCKER_TLS_VERIFY=1 

  # container java home
  JAVA_HOME=/opt/java/openjdk

  # container jenkins home
  JENKINS_HOME=/var/jenkins_home


  # create environment file
  echo "container=${container}" > .env ;
  echo "base=${work_dir}/${container}" >> .env;
  echo "cert=${base}/${container}-cert" >> .env;
  echo "data=${base}/${container}-data" >> .env;
  echo "centos=${base}/${container}-centos" >> .env;
  echo "debian=${base}/${container}-debian" >> .env;
  echo "ubuntu=${base}/${container}-ubuntu" >> .env;
  echo "context=${base}" >> .env;
  echo "http_port=${http_port}" >> .env;
  echo "agent_port=${agent_port}" >> .env;
  echo "alias=docker" >> .env;
  echo "docker_port=2375" >> .env;
  echo "network=${container}-net" >> .env;
  echo "volume_cert=${container}-cert" >> .env;
  echo "volume_data=${container}-data" >> .env;
  echo "volume_centos=${container}-centos" >> .env;
  echo "volume_debian=${container}-debian" >> .env;
  echo "volume_ubuntu=${container}-ubuntu" >> .env;
  echo "DOCKER_TLS_CERTDIR=/certs" >> .env;
  echo "DOCKER_HOST=tcp://docker:${docker_port}" >> .env;
  echo "DOCKER_CERT_PATH=/certs/client" >> .env; 
  echo "DOCKER_TLS_VERIFY=1" >> .env; 
  echo "JAVA_HOME=/opt/java/openjdk" >> .env;
  echo "JENKINS_HOME=/var/jenkins_home" >> .env;

  ls -l .env && cat .env; 
  echo "Environment variables set successfuly";
  }

#
# Create the application directories
#
set_directories() {

  echo "Create the ${container} directory structure";

  [ ! -d ${work_dir} ] && sudo mkdir -p ${work_dir} ;

  sudo chgrp docker ${work_dir};
  sudo chmod g+rwx ${work_dir};

  # create jenkins directory structure
  [ ! -d ${cert} ] && sudo mkdir -p ${cert};
  [ ! -d ${data} ] && sudo mkdir -p ${data};
  [ ! -d ${centos} ] && sudo mkdir -p ${centos};
  [ ! -d ${debian} ] && sudo mkdir -p ${debian};
  [ ! -d ${ubuntu} ] && sudo mkdir -p ${ubuntu};
  
  sudo chown -R jenkins:docker ${base};
  sudo chmod -R g+rwx ${base};

  # Copy docker files to context
  sudo cp ../container/*.Dockerfile ${base} ;
  sudo cp ../container/docker-compose.yaml ${base}; 

  sudo chown jenkins:docker .env;
  sudo mv .env ${base} && sudo chown jenkins:docker ${base}/.env;

  echo "Directory structure completed successfully.";
  tree ${base};
}

#
# Set up the SSH keys
#
set_ssh() {
  echo "Create the SSH key";
  ssh-keygen -b 4096 -f ${base}/jkey -N '' -q -t rsa ;
  sudo cp ./sshd_config ${base};
  ls -l ${base}/jkey* ${base}/sshd_config;
  echo "SSH Key created successfully.";
}

#
# Create the Jenkins container
#
set_container() {
  source ${base}/.env;

  # Create the jenkins contaienr
  echo "Create the Jenkins containers"; 
  docker compose -p ${container} -f ${base}/docker-compose.yaml up -d  

  # list volumes
  echo "Docker Volumes";
  docker volume ls 
  echo;

  # list network
  echo "Docker Networks";
  docker network ls
  echo;

  # show docker containers
  echo "Docker Containers";
  docker ps ;
  echo;

  # Show jenkins initial admin password
  docker logs ${container} 
  echo ;
}

#
# Main
#
version=22.10.15;

#
# Set the Jenkins default values
#
set_default_values;

#
# Dinamyc options
#
while [ "$#" -gt 0 ] ; do
  key="$1" ;
  shift ;
  case $key in
    -a|--agent-port) agent_port="$1" && shift ;;
    -c|--container)  container="$1" && shift ;;
    -i|--instance-number) instance_number="$1" && shift ;;
    -p|--http-port)  http_port="$1" && shift ;;
    -w|--work-dir)   work_dir="$1" && shift ;;
    *) echo "Error: unkown option." && show_usage ;;
  esac;
done;

#
# Process Steps
#
set_env;         # Set the environment variables
set_directories; # Create the directory tree
set_ssh;         # Create the SSH RSA key
set_container;   # Set up the containers
