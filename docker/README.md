# :ship: Running Jenkins on a Docker container
Applicable for macOS and Linux

## From Docker Command Line
1. Define the variables to be used.

    ```bash
    # application name
    app=jenkins;

    # application group number
    grpno=1; 

    # network name   
    network=jnet;

    # network alias
    alias=docker;

    # application port
    bport=8080
    port=$(( $bport + $grpno ))

    # Application storage
    storage=/app/data/storage/cicd${grpno};
    ```

2. Create the docker volumes.
    
    ```bash
    # Create the storage dir
    [ ! -d ${storage} ] && sudo mkdir -p ${storage};
    
    docker volume create --driver local --name ${app}-data 
    docker volume create --driver local --name ${app}-docker-certs 
    
    docker volume ls
    ```
    
3. Create the bridge network.
    
    ```bash
    docker network create ${network}
    docker network ls
    ```

4. Issue the docker command to create the Jenkins Container.
    ```bash
    docker run \
      --detach \
      --env DOCKER_HOST=tcp://docker:2376 \
      --env DOCKER_CERT_PATH=/certs/client \
      --env DOCKER_TLS_VERIFY=1 \
      --name ${app} \
      --network ${network} \
      --network-alias ${alias} \
      --publish ${port}:8080 \
      --publish 50000:50000 \
      --restart=on-failure \
      --user root \
      --volume ${storage}/${app}-data:/var/jenkins_home \
      --volume ${storage}/${app}-docker-certs:/certs/client:ro \
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

    :five: `--publish 8088:8080 --publish 50000:50000 ` 	
    - Maps (i.e. "publishes") port 8080 of the current container to port 8080 on the host machine. The first number represents the port on the host while the last represents the container’s port. Therefore, if you specified -p 49000:8080 for this option, you would be accessing Jenkins on your host machine through port 49000.


    - Maps port 50000 of the current container to port 50000 on the host machine. This is only necessary if you have set up one or more inbound Jenkins agents on other machines, which in turn interact with your jenkins-blueocean container (the Jenkins "controller"). Inbound Jenkins agents communicate with the Jenkins controller through TCP port 50000 by default. You can change this port number on your Jenkins controller through the Configure Global Security page. If you were to change the TCP port for inbound Jenkins agents of your Jenkins controller to 51000 (for example), then you would need to re-run Jenkins (via this docker run …​ command) and specify this "publish" option with something like --publish 52000:51000, where the last value matches this changed value on the Jenkins controller and the first value is the port number on the machine hosting the Jenkins controller. Inbound Jenkins agents communicate with the Jenkins controller on that port (52000 in this example). Note that WebSocket agents do not need this configuration.


    :six: `--restart=on-failure` 
    - Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted.

    :seven: `--user root`
    - User in charge of creating the container volumes.

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
    docker ps | grep ${app} # or docker container ls
    curl localhost:${port} -I
    sudo iptables -S -t nat | grep :$8080
    ```

6. Complete the installation steps from a support web browser.
- Open a browser to `http://localhost:${port}` address.
- Get the password needed to unlock the Getting Started screen.
    
    ```bash
    docker exec ${app} cat /var/jenkins_home/secrets/initialAdminPassword
    ```
    
- Verify the container logs
    
    ```bash
    docker logs ${app}
    ```
    
- Follow the steps set up on [Configure Jenkins After Installation](https://www.notion.so/Configure-Jenkins-after-installation-9d6ffa4ea6224bd286ebb91cab36ff57).
- Test the Jenkins container with the `wget` command.
    
    ```bash
    sudo docker exec ${app} wget http://localhost:${port} -O - -q
    ```




Docker file for ubuntu
```
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpgs
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.6 docker-workflow:1.29"
```


