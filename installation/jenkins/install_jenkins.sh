#
# Create the env variables file
#
set_env() {

  echo "/*** Set environment variables ***/";

  # application name
  container=jenkins;

  # application port
  http_port=8080;

  # agent port
  agent_port=50000;

  # Application working directory
  work_dir=/app/data;

  # Jenkins base
  base=`echo ${work_dir}/${container}`;

  # docker network name   
  network=`echo ${container}_net`;

  # Jenkins data directory
  data_dir=`echo ${base}/jenkins_home`;

  # volume alias data
  volume_data=`echo ${container}_data`;

  # image name
  image='jenkins-blueocean:2.387-jdk11';

  # container java home
  JAVA_HOME=/opt/java/openjdk;

  # container jenkins home
  JENKINS_HOME=/var/jenkins_home;

  # default username
  username=jenkins;

  # default ssh key filename
  ssh_key=`echo ${username}_key`;

  # create environment file
  echo "context=${base}" > .env;
  echo "image=${image}" >> .env;
  echo "container=${container}" >> .env ;
  echo "agent_port=${agent_port}" >> .env;
  echo "http_port=${http_port}" >> .env;
  echo "network=${network}" >> .env;
  echo "data_dir=${data_dir}" >> .env;
  echo "volume_data=${volume_data}" >> .env;
  echo "JAVA_HOME=${JAVA_HOME}" >> .env;
  echo "JENKINS_HOME=${JENKINS_HOME}" >> .env;
  echo "username=${username}" >> .env;
  echo "ssh_key=${ssh_key}" >> .env;

  ls -l .env && cat .env; 

  echo "/*** Environment variables set successfuly ***/";
}


#
# Install docker
# 
set_docker() {

  #
  # Set up the repository
  #
  # remove old docker versions
  sudo apt remove -y docker docker-engine docker.io containerd runc ;

  # Update the apt package index and install packages to allow apt to use a repository over HTTPS:
  sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release ;

  # Add Docker’s official GPG key
  [ ! -d /etc/apt/keyrings ] && sudo mkdir -p /etc/apt/keyrings ;
  [ -f /etc/apt/keyrings/docker.gpg ]  && sudo mv /etc/apt/keyrings/docker.gpg /tmp ;
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg ;

  # Set up the Docker repository
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null ;

  #
  # Install Docker Engine
  #
  sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin ;

  # add docker group to user
  sudo groupadd docker;
  sudo usermod -aG docker ${USER};
  
  # Commands to avoid permission errors
  sudo chown root:docker /var/run/docker.sock
  sudo chown ${USER}:${USER} /home/${USER}/.docker -R ;
  sudo chmod g+rwx "$HOME/.docker" -R ;

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
  [ ! -d ${data_dir} ] && sudo mkdir -p ${data_dir};
  
  sudo chown -R $USER:docker ${base};
  sudo chmod -R g+rwx ${base};
  sudo chown $USER:docker .env;

  echo "Directory structure completed successfully.";
  tree ${base};
}

#
# Set up the SSH keys
#
set_ssh() {
  echo "/*** Create the SSH key ***/";
  [ -f ./${ssh_key} ] && rm -f ./${ssh_key};
  [ -f ./${ssh_key}.pub ] && rm -f ./${ssh_key}.pub;
  ssh-keygen -f ./${ssh_key} -N '' -q -t ed25519 -C "${username}";
  ls -l ./${ssh_key}* ./sshd_config;
  echo "/*** SSH Key created successfully ***/";
}


#
# Create the Jenkins container
#
set_container() {
  source .env;

  # Create the jenkins contaienr
  echo "Create the Jenkins containers"; 
  sudo docker compose -p ${container} -f docker-compose.yml up -d  

  # list volumes
  echo "Docker Volumes";
  sudo docker volume ls 
  echo;

  # list network
  echo "Docker Networks";
  sudo docker network ls
  echo;

  # show docker containers
  echo "Docker Containers";
  sudo docker ps ;
  echo;

  # Show jenkins initial admin password
  sleep 3;
  sudo docker logs ${container} 

  # Get the Jenkins Initial Admin Password
  echo "Jenkins Initial Admin Password: `sudo docker exec -it ${container} cat /var/jenkins_home/secrets/initialAdminPassword`"
}

#
# Mains
#
version=23.01.26;

#
# Process Stepss
#
set_env;         # Set the environment variables
set_docker;
set_directories; # Create the directory tree
set_ssh;         # Create the SSH RSA key
set_container;   # Set up the containerss
