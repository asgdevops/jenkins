# :notes: Running Jenkins on a container within Docker
_Applicable for macOS and Linux_

## :paw_prints: Steps
1. Define the Jenkins instance variables to be used.

    ```bash
        # application group number
        instance_number=0; 

        # application name
        app_name=jenkins${instance_number};

        # network name   
        network=${app_name}net;

        # network alias
        alias=docker;

        # application port
        default_port=8080
        http_port=$(( $default_port + $instance_number ))

        # agent port
        default_agent_port=50000
        agent_port=$(( $default_agent_port + $instance_number ))

        # docker engine port
        docker_port=2376

        # Application storage
        storage=/app/data/storage/${app_name};
    ```

2. Create the docker volumes.
    
    ```bash
    # Create the storage dir
    [ ! -d ${storage} ] && sudo mkdir -p ${storage};
    
    docker volume create --driver local --name ${app_name}-data 
    docker volume create --driver local --name ${app_name}-docker-certs 
    
    docker volume ls
    ```
    
3. Create a bridge network to connect the Docker engine container with the Jenkins one.
    
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
    --volume ${storage}/${app_name}-docker-certs:/certs/client \
    --volume ${storage}/${app_name}-data:/var/jenkins_home \
    docker:dind 
    ```

5. Customise official Jenkins Docker image, by executing below two steps:

   - Create Dockerfile with the following content:

        ```Docker
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
        ```

   - Build a new docker image from this Dockerfile and assign the image a meaningful name, e.g. "jenkins-blueocean:2.346.3-1":

        ```bash
        docker build . -t jenkins/blueocean:2.346.3-1
        ```

   - Keep in mind that the process described above will automatically download the official Jenkins Docker image if this hasn’t been done before.

6. Run your own myjenkins-blueocean:2.346.3-1 image as a container in Docker using the following docker run command:

    ```bash
    docker run \
    --detach \
    --env DOCKER_HOST=tcp://docker:${docker_port} \
    --env DOCKER_CERT_PATH=/certs/client \
    --env DOCKER_TLS_VERIFY=1 \
    --name ${app_name} \
    --network ${network} \
    --publish ${http_port}:8080 \
    --publish ${agent_port}:50000 \
    --restart=on-failure \
    --user root \
    --volume ${storage}/${app_name}-data:/var/jenkins_home \
    --volume ${storage}/${app_name}-docker-certs:/certs/client:ro \
    jenkins/blueocean:2.346.3-1
    ```

7. Alternativelly issue the docker command to create the Jenkins Container in a single step.

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
      --volume ${storage}/${app_name}-data:/var/jenkins_home \
      --volume ${storage}/${app_name}-docker-certs:/certs/client:ro \
      jenkins/jenkins:lts
    ```

    ***Command explanation***:

    :zero: `--detach` 
    - Runs the Docker container in the background. This instance can be stopped later by running `docker stop jenkins`. 

    :one: `--env` 
    - Specifies the environment variables used by **docker**, **docker-compose*, and other Docker tools to connect to the Docker daemon from the previous step.

    :two: `--name` 
    - Specifies the Docker container name to use for running the image. By default, Docker will generate a unique name for the container.

    :three: `--network` and `network-alias`
    - Connects this container to the network defined in the earlier step. This makes the Docker daemon from the previous step available to this Jenkins container through the hostname docker. 

    :four: `--privileged` 
    - Running Docker in Docker currently requires privileged access to function properly. This requirement may be relaxed with newer Linux kernel versions.

    :five::a: `--publish ${port}:8080` 	
    - Maps (i.e. "publishes") port 8080 of the current container to port 8080 on the host machine. The first number represents the port on the host while the last represents the container’s port. Therefore, if you specified -p 49000:8080 for this option, you would be accessing Jenkins on your host machine through port 49000.

    
    :five::b: `--publish 50000:50000`

    - Maps port 50000 of the current container to port 50000 on the host machine. This is only necessary if you have set up one or more inbound Jenkins agents on other machines, which in turn interact with your jenkins container (the Jenkins "controller"). Inbound Jenkins agents communicate with the Jenkins controller through TCP port 50000 by default. You can change this port number on your Jenkins controller through the Configure Global Security page. If you were to change the TCP port for inbound Jenkins agents of your Jenkins controller to 51000 (for example), then you would need to re-run Jenkins (via this docker run …​ command) and specify this "publish" option with something like --publish 52000:51000, where the last value matches this changed value on the Jenkins controller and the first value is the port number on the machine hosting the Jenkins controller. Inbound Jenkins agents communicate with the Jenkins controller on that port (52000 in this example). Note that WebSocket agents do not need this configuration.


    - The port format is `HOST:CONTAINER` 


    :six: `--restart=on-failure` 
    - Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted.

    :seven: `--user root` 
    - Set root as the default user.

    :eight: `--volume jenkins-data:/var/jenkins_home`
    - Maps the /var/jenkins_home directory inside the container to the Docker volume named jenkins-data. This will allow for other Docker containers controlled by this Docker container’s Docker daemon to mount data from Jenkins.

    - Instead of mapping the /var/jenkins_home directory to a Docker volume, you could also map this directory to one on your machine’s local file system. For example, specifying the option `--volume $HOME/jenkins:/var/jenkins_home` would map the container’s `/var/jenkins_home` directory to the jenkins subdirectory within the `$HOME` directory on your local machine, which would typically be `/Users/<your-username>/jenkins` or `/home/<your-username>/jenkins`. Note that if you change the source volume or directory for this, the volume from the docker:dind container above needs to be updated to match this.


    :nine: `-volume jenkins-docker-certs:/certs/client:ro`

    - Maps the `/certs/client` directory to the previously created `jenkins-docker-certs` volume. This makes the client TLS certificates needed to connect to the Docker daemon available in the path specified by the DOCKER_CERT_PATH environment variable.


    :keycap_ten: `jenkins/jenkins:lts`
    - The jenkins image itself. This image can be downloaded before running by using the command: docker image pull `jenkins/jenkins:lts`.

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
    a. Use the automated [create_jenkins.sh](app/jenkins_base/create_jenkins.sh) script. 
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
   - `'-s' | '--storage':` Jenkins local storage directory.

   Example:

   `create_jenkins.sh --app-name protoj`


### Docker-compose approach
1. Create the environment variables `.env` file including the SSH public key just generated.
   
    ```bash
    # application name
    app_name=jenkins

    # agent port
    agent_port=50000

    # application context
    context=`pwd`

    # application port
    http_port=8080

    # Application storage
    storage=/app/data/storage/jenkins

    # Jenkins variables
    jenkins_home=/var/jenkins_home

    # Volumes name
    volume_id=jenkins-data
    ```

2. Create the docker file.

    ```Ansible
    # docker-compose.yaml
    version: "3.9"

    volumes:
    data:
        driver: local
        driver_opts:
        type: 'none'
        o: 'bind'
        device: "${storage}"
        name: ${volume_id}

    services:
    jenkins:
        build:
            context: ${context}
        container_name: "${app_name}"
        environment:
            - JENKINS_HOME = ${jenkins_home}
        image: jenkins/jenkins:lts
        ports:
            - "${http_port}:8080/tcp"
            - "${agent_port}:50000/tcp"
        privileged: true
        restart: on-failure
        user: jenkins
        networks: 
            - net
        volumes:
            - data:${jenkins_home}
        working_dir: "${jenkins_home}"

    networks: 
        net:
            driver: bridge
   ```


3. Startup the jenkins and agent containers.

    ```
    docker-compose -p jenkins up -d
    ```

# :scroll: Scripts
- [create_jenkins.sh](app/jenkins_base/create_jenkins.sh)
- [docker-compose.yaml](app/jenkins_base/docker-compose.yaml)

# :books: References 
- [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker run](https://docs.docker.com/engine/reference/commandline/run/)
- [How to install Jenkins on Docker](https://octopus.com/blog/jenkins-docker-install-guide#how-to-install-jenkins-on-docker)
- [Jenkins Blueocean plugin releases](https://github.com/jenkinsci/blueocean-plugin/releases)
- [Jenkins docker-flow plugin releases](https://github.com/jenkinsci/docker-workflow-plugin/releases)
- [Using volumes in Docker'compose](https://devopsheaven.com/docker/docker-compose/volumes/2018/01/16/volumes-in-docker-compose.html)