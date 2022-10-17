# :notebook: Running Jenkins on a container using scripts
_Applicable for macOS and Linux_

## :paw_prints: Steps
1. Set up jenkins user account on the linux host.
 
    ```bash
    # switch to root user
    sudo su -

    # RHEL based
    useradd -m -g wheel -G docker jenkins

    # Debian based
    useradd -m -g sudo -G docker jenkins

    # Gice a password to jenkins accounts
    passwd jenkins
    ```

2. Create the environment variables `.env` file.

    ```bash
    # Working directory
    work_dir=/app/data;

    # jenkins instance name
    app_name="jenkins79";

    # Jenkins base
    app_base=${work_dir}/${app_name};

    # Jenkins certs
    app_cert="${app_base}/${app_name}-cert";

    # Jenkins data
    app_data="${app_base}/${app_name}-data";

    # Jenkins home
    app_home=${app_data}/app_home;

    # jenkins http port
    http_port=8079;

    # jenkins agent port
    agent_port=50079;

    # docker container network alias
    alias=docker;

    # docker engine port
    docker_port=2375;

    # docker network name   
    network="${app_name}-net";

    # volume cert alias
    volume_cert="${app_name}-cert";

    # volume data alias
    volume_data="${app_name}-data";

    # volume home alias
    volume_home="${app_name}-home";

    # Container Environment Variables 
    # container java home
    JAVA_HOME=/opt/java/openjdk

    # container jenkins home
    JENKINS_HOME=/var/app_home
    ```

3. Create the jenkins directories.

    ```bash
    source .env ;

    # create the working directory if not exists
    [ ! -d ${work_dir} ] && mkdir -p ${work_dir}; 

    chgrp docker ${work_dir};
    chmod g+rwx ${work_dir};

    # creante jenkins, cert, data and home directories
    [ ! -d ${app_cert} ] && mkdir -p ${app_cert};
    [ ! -d ${app_home} ] && mkdir -p ${app_home};

    chown -R jenkins:docker ${app_base};
    chmod -R g+rwx ${app_base};

    chown jenkins:docker .env;
    mv .env ${app_base} && chown jenkins:docker ${app_base}/.env;
    cd ${app_base};
    ```

5. Switch to jenkins user and source the environment variables.

    ```bash
    su jenkins ;
    bash ;
    source .env ;
    ```

6. Create the docker volumes.
    
    ```bash
    docker volume create --driver local --name ${volume_data}
    docker volume create --driver local --name ${volume_cert}
    docker volume ls
    ```
    
7. Create a bridge network to connect the Docker engine container with the Jenkins one.
    
    ```Docker
    docker network create ${network}
    docker network ls
    ```

4. Create the Docker engine container. This will be used by the Jenkins container.
    
    ```Docker
    docker run \
    --detach \
    --env DOCKER_TLS_CERTDIR=/certs \
    --name ${app_name}-docker \
    --network ${network} \
    --network-alias ${alias} \
    --privileged \
    --publish ${docker_port}:${docker_port} \
    --rm \
    --volume ${volume_cert}:/certs/client \
    --volume ${volume_data}:/var/jenkins_home \
    docker:dind 
    ```

5. Customise official Jenkins Docker image, by executing below two steps:

   - Create Dockerfile with the following content:

        ```Docker
        tee jenkins.Dockerfile<<EOF
        FROM jenkins/jenkins:2.346.3-jdk11
        USER root
        RUN apt-get update && apt-get install -y lsb-release
        RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
            https://download.docker.com/linux/debian/gpg
        RUN echo "deb [arch=$(dpkg --print-architecture) \
            signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
            https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
        RUN apt-get update && apt-get install -y docker-ce-cli
        USER jenkins
        RUN jenkins-plugin-cli --plugins "blueocean:1.25.7 docker-workflow:1.29"
        EOF
        ```

   - Build a new docker image from this Dockerfile and assign the image a meaningful name, e.g. "jenkins-blueocean:2.346.3-1":

        ```bash
        docker build . -f jenkins.Dockerfile -t jenkins/blueocean:2.346.3-1
        ```

   - Keep in mind that the process described above will automatically download the official Jenkins Docker image if this hasn’t been done before.

6.  Run your own myjenkins-blueocean:2.346.3-1 image as a container in Docker using the following docker run command:

    ```bash
    docker run \
    --detach \
    --env DOCKER_HOST=tcp://docker:${docker_port} \
    --env DOCKER_CERT_PATH=/certs/client \
    --env DOCKER_TLS_VERIFY=1 \
    --name ${app_name} \
    --network ${network} \
    --network-alias ${alias} \
    --publish ${http_port}:8080 \
    --publish ${agent_port}:50000 \
    --restart=on-failure \
    --user root \
    --volume ${app_home}:/var/app_home \
    --volume ${app_cert}:/certs/client:ro \
    jenkins/blueocean:2.346.3-1
    ```

7.  Alternativelly issue the docker command to create the Jenkins Container in a single step.

    ```bash
    docker run \
      --detach \
      --env DOCKER_HOST=tcp://docker:${docker_port} \
      --env DOCKER_CERT_PATH=/certs/client \
      --env DOCKER_TLS_VERIFY=1 \
      --name ${app_name} \
      --network ${network} \
      --network-alias ${alias} \
      --publish ${http_port}:8080 \
      --publish ${agent_port}:50000 \
      --restart=on-failure \
      --user root \
      --volume ${app_home}:/var/app_home \
      --volume ${app_cert}:/certs/client:ro \
      jenkins/jenkins:lts
    ```

<br/>

5. Review the container got installed properly.

    ```bash
    docker ps | grep ${app_name} # or docker container ls
    curl localhost:${http_port} -I
    sudo iptables -S -t nat | grep :${default_port}
    ```

6. Complete the installation steps from a web browser.
   - Open the application `http://localhost:${http_port}` on a Web browser.
   - Get the password needed to unlock the **Getting Started** screen.
    
    ```bash
    docker exec ${app_name} cat /var/jenkins_home/secrets/initialAdminPassword
    ```
    
   - Verify the container logs
    
    ```bash
    docker logs ${app_name}
    ```
    
- Follow the [Configure Jenkins After Installation](https://www.notion.so/Configure-Jenkins-after-installation-9d6ffa4ea6224bd286ebb91cab36ff57) to complete the installation.


## Installing Jenkins with Dockercompose
There are two possible ways to achieve this:
    a. Use the automated [create_jenkins.sh](app/app_base/create_jenkins.sh) script. 
    b. Create the `.env` variables and the `docker-compose.yaml` files to issue the `docker-compose` command manually.

### BASH Script approach
1. To execute the script issue:

    ```bash
    ./create_jenkins.sh
    ```

    The script options are:

   - `'-a' | '--app-name':` Application Name. 
   - `'-c' | '--context':` Working directory.
   - `'-g' | '--agent-port':` Jenkins agent port number.
   - `'-i' | '--instance-number':` Jenkins instance number.
   - `'-p' | '--http-port':` Jenkins http port number.
   - `'-s' | '--work_dir':` Jenkins local work_dir directory.

   Example:

   `create_jenkins.sh --app-name protoj`


### Docker-compose approach
1. Create the environment variables `.env` file including the SSH public key just generated.
   
    ```bash
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
    app_home=/var/app_home

    # Application work_dir
    work_dir=${work_dir}

    # Volumes name
    volume_id=${app_name}-data
    ```

2. Create the docker file.

    ```Docker
    # Jenkins Dockerfile
    FROM jenkins/jenkins:lts

    USER root

    # Install Maven
    RUN apt update -y && \
        apt install -y wget && \
        apt install -y maven
    ```

3. Create the docker-compose file.

    ```YAML
    # docker-compose.yaml
    version: "3.9"

    volumes:
    data:
        driver: local
        driver_opts:
        type: 'none'
        o: 'bind'
        device: "${work_dir}"
        name: ${volume_id}

    services:
    jenkins:
        build:
        context: ${context}
        dockerfile: "jenkins.Dockerfile"
        container_name: "${app_name}"
        env_file: 
        - ./.env
        image: "jenkins/jenkins:lts"
        ports:
        - "${http_port}:8080/tcp"
        - "${agent_port}:50000/tcp"
        privileged: true
        restart: on-failure
        user: root
        networks: 
        - net
        volumes:
        - data:${app_home}
        working_dir: "${app_home}"

    networks: 
        net:
        driver: bridge   
    ```


4. Startup the jenkins and agent containers.

    ```
    docker-compose -p jenkins up -d
    ```

# :scroll: Scripts
- [create_jenkins.sh](scripts/create_jenkins.sh)
- [jenkins.Dockerfile](scripts/jenkins.Dockerfile)
- [docker-compose.yaml](scripts/docker-compose.yaml)
- [destroy_jenkins.sh](scripts/destroy_jenkins.sh)

>_The `.env` file is created by the `create_jenkins.sh` script dynamically._

# :books: References 
- [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker run](https://docs.docker.com/engine/reference/commandline/run/)
- [How to install Jenkins on Docker](https://octopus.com/blog/jenkins-docker-install-guide#how-to-install-jenkins-on-docker)
- [Jenkins Blueocean plugin releases](https://github.com/jenkinsci/blueocean-plugin/releases)
- [Jenkins docker-flow plugin releases](https://github.com/jenkinsci/docker-workflow-plugin/releases)
- [Using volumes in Docker'compose](https://devopsheaven.com/docker/docker-compose/volumes/2018/01/16/volumes-in-docker-compose.html)
- [Jenkins : Installing Jenkins with Docker](https://wiki.jenkins-ci.org/JENKINS/Installing+Jenkins+with+Docker)
- [Reverse proxy configuration](https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-with-jenkins/)

- [How to enable SSH inside Docker container](https://www.edureka.co/community/71282/how-to-enable-ssh-inside-docker-container)
- [How to Setup Docker Containers as Build Agents for Jenkins](https://devopscube.com/docker-containers-as-build-slaves-jenkins/)
- [How to Setup Jenkins Build Agents on Kubernetes Pods](https://devopscube.com/jenkins-build-agents-kubernetes/)
- [Establish SSH connection from Jenkins container to SSH server container, I can establish with password login but can't establish with private key](https://stackoverflow.com/questions/63969833/establish-ssh-connection-from-jenkins-container-to-ssh-server-container-i-can-e)
