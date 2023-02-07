#!/usr/bin/bash
#
# Create the env variables file
#
set_env() {


  # application name
  container=jenkins;

  # Application working directory
  work_dir=/app/data;

  # Jenkins base
  base=${work_dir}/${container};

  # docker network name   
  network=${container}_net;

  # volume data alias
  volume_data=${container}_data;
}

#
# Create the application directories
#
remove_directories() {
  echo "Removing the ${container} directories...";
  [ -d ${base} ] && sudo rm -rf ${base} ;
  echo "Process completed successfully.";
}


#
# Create the Jenkins container
#
remove_container() {
  echo "Removing the docker ${container}";
  cd ${base};

  # Create the jenkins contaienr
  sudo docker compose down 

  # list volumes
  sudo docker volume rm ${volume_cert}  ${volume_data}
  sudo docker volume prune -f 
  sudo docker volume ls

  # list network
  sudo docker network rm  ${network}
  sudo docker network ls

  # show docker instances 
  sudo docker ps ;
  echo "Process completed successfully.";
}


#
# Remove Docker
#
remove_docker() {
  sudo service docker stop && sudo apt purge -y `dpkg -l | grep -i docker | awk '{ print $2 }'`
  sudo rm -rf /var/lib/docker /etc/docker;
  sudo groupdel docker;
  sudo rm -rf /var/run/docker.sock;
}

remove_keys(){
  rm -f ./${container}_key
}

#
# Main
#
version=23.01.26;

set_default_values;
set_env;
remove_container;  
remove_directories;
remove_docker;
remove_keys;