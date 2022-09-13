# Create a new Jenkins instance

#
# show usage
#
show_usage() {
  echo -e "\nUsage:\n
  ./$(basename ${0}) { <option1> <value1> .. <option..n> <value..n> } \n
Options:\n
  '-a' | '--app-name':        Application Name \n
  '-c' | '--context':         Working dir \n
  '-g' | '--agent-port':      Jenkins agent port \n
  '-i' | '--instance-number': Jenkins instance number \n
  '-p' | '--http-port':       Jenkins http port number \n
  '-s' | '--storage':         Jenkins local directory \n
\n
Example:\n
  ./$(basename ${0}) --app-name jenkins \n"
}


set_default_values() {
    # application group number
    instance_number=0; 

    # application name
    if [ ${instance_number} -gt 0 ] ; then
        app_name=jenkins${instance_number};
    else
        app_name=jenkins;
    fi

    # application port
    default_http_port=8080
    http_port=$(( $default_http_port + $instance_number ))

    # agent port
    default_agent_port=50000
    agent_port=$(( $default_agent_port + $instance_number ))

    # Application working directory
    storage=/app/data/storage/${app_name};

    # Application working directory
    context=`pwd`;
}

#
# Main
#
version=22.09.05;

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
		-a|--app-name)
			app_name="$1";
			shift ;
		;;
		-c|--context)
			context="$1";
			shift ;
		;;
		-g|--agent-port)
			agent_port="$1";
			shift ;
		;;
		-i|--instance-number)
			instance_number="$1";
			shift ;
		;;
		-p|--http-port)
			http_port="$1";
			shift ;
		;;
		-s|--storage)
			storage="$1";
			shift ;
		;;
		*)
		   echo "Error: unkown option.";
           show_usage ;
		;;
	esac;
done;

# Create the application directory if not exists
[ ! -d ${storage} ] && sudo mkdir -p ${storage} ;

cd ${context} ;

#
# Create the docker variables file
#
tee .env <<EOF
# application name
app_name=${app_name}

# agent port
agent_port=${agent_port}

# application context
context=${context}

# application port
http_port=${http_port}

# Java home
JAVA_HOME=/opt/java/openjdk

# Jenkins variables
JENKINS_HOME=/var/jenkins_home

# Application storage
storage=${storage}

# Volumes name
volume_id=${app_name}-data
EOF

docker-compose -p ${app_name} up -d ;
