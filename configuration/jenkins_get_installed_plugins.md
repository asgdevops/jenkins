# :information_source: Get the plugins installed on Jenkins

## :paw_prints: Steps

### Requisites
- [Configure a new API Token](jenkins_configure_api_token.md) for the user in charge of running the plugin scripts.


    Admin user token example: 
    ```
    11d5c612452c2a6901b3891cdb2d359997
    ```

## :one: Get the Jenkins installed plugins with the Groovy script.

1. Create the [Groovy script](scripts/plugins_script_console.groovy) file on your local host.
    ```Groovy
    Jenkins.instance.pluginManager.plugins.each{
    plugin -> 
        println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
    }
    ```

2. Issue a cURL command  calling the Groovy script.
    ```bash
    curl -d "script=$(cat jenkins_plugin_list.groovy)" -v --user admin:1101af44c0838435c765ffcf7aa78ffeb6 http://localhost:8081/script
    ```

- Optionally the same command could be issued inside a Docker container:
    ```bash
    docker exec jenkins curl -u admin:1101af44c0838435c765ffcf7aa78ffeb6 http://localhost:8080/script
    ```

## :two: Get the plugins using jenkins-cli

1. Get the **jenkins-cli** utility from Jenkins.
    ```bash
    curl 'localhost:8081/jnlpJars/jenkins-cli.jar' > jenkins-cli.jar
    ```
2. Create the [plugins.groovy](scripts/plugins.groovy) script.

    ```groovy
    def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins() plugins.each {println "${it.getShortName()}: ${it.getVersion()}"}
    ```

3. Run the jenkins-cli tool to get the list of plugins installed on Jenkins.
    ```bash
    java -jar jenkins-cli.jar -s http://localhost:8081 -auth admin:1101af44c0838435c765ffcf7aa78ffeb6 groovy = < plugins.groovy > plugins.txt
    ```

# :books: References
- [Jenkins-plugins](https://gist.github.com/noqcks/d2f2156c7ef8955619d45d1fe6daeaa9)
- [Jenkins — Getting a List of installed Jenkins Plugins with name and Version.](https://medium.com/@mukul37/jenkins-getting-a-list-of-installed-jenkins-plugins-with-name-and-version-3ee3e2b26e24)