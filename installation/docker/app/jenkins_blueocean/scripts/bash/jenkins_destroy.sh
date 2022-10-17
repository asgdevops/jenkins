#!/usr/bin/bash
# Create a new Jenkins instance

#
# show usage
#
show_usage() {
  echo -e "\nUsage:\n
  ./$(basename ${0}) { <option1> <value1> .. <option..n> <value..n> } \n
Options:\n
  '-c' | '--container':   Container Name \n
  '-w' | '--work-dir':    Jenkins Working directory \n
\n
Example:\n
  ./$(basename ${0}) --app-name jenkins \n"
}

set_default_values() {
  # application name
  container=jenkins;

  # Application working directory
  work_dir=/app/data;
}


#
# Create the env variables file
#
set_env() {

  # Jenkins base
  base=${work_dir}/${container};

  # docker network name   
  network=${container}_net;

  # volume cert alias
  volume_cert=${container}-cert;

  # volume data alias
  volume_data=${container}-data;
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
  docker compose down 

  # list volumes
  docker volume rm ${volume_cert}  ${volume_data}
  docker volume prune -f 
  docker volume ls

  # list network
  docker network rm  ${network}
  docker network ls

  # show docker instances 
  docker ps ;
  echo "Process completed successfully.";
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
    -c|--container)  container="$1" && shift ;;
    -w|--work-dir)   work_dir="$1" && shift ;;
    *) echo "Error: unkown option." && show_usage ;;
  esac;
done;


set_env;
remove_container;  
remove_directories;
