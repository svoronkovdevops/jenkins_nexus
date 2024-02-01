# Jenkins

## Content


[Installing](#installing)

[Nexus](#nexus)

[SSh to GitHub](#ssh-to-github)

[Maven configuration](#maven-configuration)

[Gradle configuration](#gradle-configuration)

[Docker](#docker)

[Basic settings.xml example](#basic-settingsxml-example)



## Installing

`sudo apt-get update`

`java --version`

`sudo apt install openjdk-11-jre-headless` install java if we don't have  or 17 version `sudo apt install fontconfig openjdk-17-jre`

`java --version`



```sh

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

``` 


`systemctl status jenkins`

`systemctl enable jenkins`

### Configure JVM:


`sudo vi /lib/systemd/system/jenkins.service`

add:

```service
JAVA_OPTS=-Djava.awt.headless=true -XX:+AlwaysPreTouch -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/jenkins/log -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -Xlog:gc=info,gc+heap=debug,gc+ref*=debug,gc+ergo*=trace,gc+age*=trace:file=/var/lib/jenkins/gc.log:utctime,pid,level,tags:filecount=2,filesize=100M -Xmx512m -Xms512m
```
sudo AVA_OPTS=-Djava.awt.headless=true -XX:+AlwaysPreTouch -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/jenkins/log -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -Xlog:gc=info,gc+heap=debug,gc+ref*=debug,gc+ergo*=trace,gc+age*=trace:file=/var/lib/jenkins/gc.log:utctime,pid,level,tags:filecount=2,filesize=100M -Xmx512m -Xms512m >> /lib/systemd/system/jenkins.service

NOTE*
`-Xmx512m -Xms512m` depends on free memory on pc or vm without memory for OS


### Run Jenkins

`sudo systemctl daemon-reload`

`sudo systemctl restart jenkins`

Open incognito mode browser: http://your_host

Find password: `cat /var/lib/jenkins/secrets/initialAdminPassword`

install Suggest Plugin

Add user


[Content](#content)


### Password

`vagrant up`  - run jenkins on VM Box

vagrant ssh jenk - connect from powerShell to VM's terminal

password vagrant 

username vagrant

http://100.0.0.7:8080

`sudo cat /var/lib/jenkins/secrets/initialAdminPassword` will print the password at console.

If you are running Jenkins in Docker using the official jenkins/jenkins image you can use 

`sudo docker exec ${CONTAINER_ID or CONTAINER_NAME} cat /var/jenkins_home/secrets/initialAdminPassword` to print the password in the console without having to exec into the container.



## Nexus

https://github.com/svoronkovdevops/sonatype_nexus.git

`vagrant up`  - run nexus on VM Box

vagrant ssh nexus - connect from powerShell to VM's terminal

password: vagrant 

username: vagrant


http://100.0.0.16:8081


### Problems

connect to terminal `vagrant ssh nexus`

```sh
cd /opt/nexus-3.60.0-02/bin

./nexus run 

./nexus restart

./nexus stop 
```


[Content](#content)


## SSh to GitHub

ssh-keygen -t rsa -b 4096 -C "vsv"

eval "$(ssh-agent -s)"

ssh-add vsv

git@github.com:VSVDEv/model.git


->gitHub -> settings -> ssh -> create key and copy your public key
-> jenkins -> manage jenkins-> credentials-> add credentials -> ssh-> add private key

```groovy
   stage("Git Clone"){

        git credentialsId: 'GIT_HUB', url: 'git@github.com:VSVDEv/model.git'
        
        sh "ls -ll"
    }
```



```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
              //  git credentialsId: 'git_vsvdev', url: 'git@github.com:VSVDEv/model.git'
             // git branch: 'main', url: 'https://github.com/VSVDEv/model.git'
             git 'https://github.com/VSVDEv/model.git'
                sh "ls -ll"
            }
        }
        stage('Test and compile') {
            steps {
               echo "*****************Cleaning...."
               sh "mvn clean"
               echo "*****************Completed clean"
               
               sh "mvn compile"
               echo "*****************Finish Compiling"
	           echo '*****************Run unit tests'
	           sh "mvn package"
               echo '*****************Package finished'
            }
        }
        stage('Deploy') {
            steps {
               echo "*****************Start deploy"
               sh "mvn -Dmaven.test.skip=true -Dmaven.main.skip=true deploy"
            }
        }
    }
}
```
[Content](#content)


## Maven configuration

/var/lib/jenkins/.m2/
/usr/share/maven/conf

settings.xml


```xml

<server>
      <id>nexus</id>
      <username>developer</username>
      <password>123</password>
</server>
```


```xml

<server>
      <id>nexus</id>
      <username>jenkins_mav</username>
      <password>123</password>
</server>
```

```xml
<mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://100.0.0.16:8081/repository/sv/</url>
    </mirror>
  </mirrors>
```


```xml
<distributionManagement>
    <repository>
      <id>nexus</id>
      <name>Releases</name>
      <url>http://100.0.0.16:8081/repository/sv/</url>
    </repository>
    <snapshotRepository>
      <id>nexus</id>
      <name>Snapshot</name>
      <url>http://localhost:8081/repository/maven-snapshots</url>
    </snapshotRepository>
  </distributionManagement>
```


```xml
<repositories>
<repository>
<id>nexus</id>
<url>http://100.0.0.16:8081/repository/sv/</url>
</repository>
</repositories>
```






```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
           
             git 'https://github.com/VSVDEv/micro.git'
                sh "ls -ll"
            }
        }
       
        stage('Deploy') {
            steps {
               echo "*****************Start deploy"
               sh "mvn deploy"
            }
        }
    }
}
```

/usr/share/maven/conf

settings.xml

https://help.sonatype.com/en/quick-start-guide---proxying-maven-and-npm.html

Result file settings.xml

```xml

<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

<pluginGroups>

</pluginGroups>

<proxies>

</proxies>

<servers>
<server>
      <id>nexus-pr</id>
      <username>jenk</username>
      <password>123</password>
</server>
<server>
      <id>nexus</id>
      <username>jenk</username>
      <password>123</password>
</server>
</servers>

<mirrors>
  <mirror>
  <!--This sends everything else to /public -->
  <id>nexus</id>
  <mirrorOf>*</mirrorOf>
  <url>http://100.0.0.16:8081/repository/sv-proxy/</url>
  </mirror>
</mirrors>
<profiles>
  <profile>
  <id>nexus</id>
  <!--Enable snapshots for the built in central repo to direct -->
  <!--all requests to nexus via the mirror -->
  <repositories>
      <repository>
      <id>central</id>
      <url>http://central</url>
      <releases><enabled>true</enabled></releases>
      <snapshots><enabled>true</enabled></snapshots>
      </repository>
  </repositories>
  <pluginRepositories>
      <pluginRepository>
      <id>central</id>
      <url>http://central</url>
      <releases><enabled>true</enabled></releases>
      <snapshots><enabled>true</enabled></snapshots>
      </pluginRepository>
  </pluginRepositories>
  </profile>
</profiles>
<activeProfiles>
  <!--make the profile active all the time -->
  <activeProfile>nexus</activeProfile>
</activeProfiles>

   
</settings>
```


/usr/share/maven/conf

settings.xml


```xml

<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

<pluginGroups>

</pluginGroups>

<proxies>

</proxies>

<servers>
<server>
      <id>nexus-pr</id>
      <username>jenk</username>
      <password>123</password>
</server>
<server>
      <id>nexus</id>
      <username>jenk</username>
      <password>123</password>
</server>
</servers>

<mirrors>
  <mirror>
  <!--This sends everything else to /public -->
  <id>nexus-pr</id>
  <mirrorOf>*</mirrorOf>
  <url>http://100.0.0.16:8081/repository/sv-group/</url>
  </mirror>
</mirrors>
<profiles>
  <profile>
  <id>nexus</id>
  <!--Enable snapshots for the built in central repo to direct -->
  <!--all requests to nexus via the mirror -->
  <repositories>
      <repository>
      <id>central</id>
      <url>http://central</url>
      <releases><enabled>true</enabled></releases>
      <snapshots><enabled>true</enabled></snapshots>
      </repository>
  </repositories>
  <pluginRepositories>
      <pluginRepository>
      <id>central</id>
      <url>http://central</url>
      <releases><enabled>true</enabled></releases>
      <snapshots><enabled>true</enabled></snapshots>
      </pluginRepository>
  </pluginRepositories>
  </profile>
</profiles>
<activeProfiles>
  <!--make the profile active all the time -->
  <activeProfile>nexus</activeProfile>
</activeProfiles>

   
</settings>
```

[Content](#content)


## Gradle configuration


Install Gradle Ubuntu

```sh
sudo wget -c -O /tmp/gradle-7.6.3-all.zip https://services.gradle.org/distributions/gradle-7.6.3-all.zip


sudo unzip -d /opt/gradle /tmp/gradle-7.6.3-all.zip

sudo touch /etc/profile.d/gradle.sh


sudo tee -a /etc/profile.d/gradle.sh <<EOF
export GRADLE_HOME=/opt/gradle/gradle-7.6.3
export PATH=\${GRADLE_HOME}/bin:\${PATH}
EOF

sudo chmod +x /etc/profile.d/gradle.sh

source /etc/profile.d/gradle.sh
```

### Properties

Global gradle.properties for Gradle Installation:

Another option is to have a global gradle.properties file for a specific Gradle installation.
This file can be located in the GRADLE_HOME directory.

/opt/gradle/
└── gradle-x.x.x/
    └── gradle.properties

On Windows: C:\Users\<you>\.gradle\gradle.properties
On Mac/Linux: /Users/<you>/.gradle/gradle.properties

```properties
nexusUrl=http://100.0.0.16:8081/repository/sv/
nexusUn=jenk
nexusP=123

```

### Problems with gradle access in Jenkins

Jenkins--> Manage Jenkins--> Nodes--> NodeName(your node name)--> Configure -> Node Properties
Node properties:
Environment variables:
name: GRADLE_HOME
value: /opt/gradle/gradle-7.6.3

name:PATH
value:${GRADLE_HOME}/bin:${PATH}


### Build gradle

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '2.7.15'
    id 'io.spring.dependency-management' version '1.0.15.RELEASE'
  ...
    id 'maven-publish'
}

group = 'vsvdev.co.ua'
version = '3'
def artifact = 'micro_gr'
archivesBaseName = artifact

java {
    sourceCompatibility = '11'
}

repositories {
    maven {
        url 'http://100.0.0.16:8081/repository/sv-group/'
	allowInsecureProtocol = true
        credentials {
            username = nexusUn
            password = nexusP
        }
    }
    // Other repositories can be added as needed
}




dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    // https://mvnrepository.com/artifact/net.logstash.logback/logstash-logback-encoder
    implementation group: 'net.logstash.logback', name: 'logstash-logback-encoder', version: '6.6'

}


publishing {
    publications {
        mavenJava(MavenPublication) {
            groupId project.group
            artifactId artifact
            version project.version
            from components.java
            versionMapping {
                usage('java-api') {
                    fromResolutionOf('runtimeClasspath')
                }
                usage('java-runtime') {
                    fromResolutionResult()
                }
            }
            pom {
                name = 'micro-gradle'
                description = 'microservice'
                url = 'https://github.com/VSVDEv/micro_gr.git'
                licenses {
                    license {
                        name = 'The Apache License, Version 2.0'
                        url = 'http://www.apache.org/licenses/LICENSE-2.0.txt'
                    }
                }
                developers {
                    developer {
                        id = 'VSVDev'
                        name = 'VSVDev'
                        email = 'vsvdev@ukr.net'
                    }
                }
                scm {
                    connection = 'scm:git:https://github.com/VSVDEv/micro_gr.git'
                    developerConnection = 'scm:git:https://github.com/VSVDEv/micro_gr.git'
                    url = 'https://github.com/VSVDEv/micro_gr.git'
                }
            }
        }
    }

repositories {
        maven {
             name = "sv"
            url = uri("http://100.0.0.16:8081/repository/sv/")
	    allowInsecureProtocol = true
            credentials {
                username = nexusUn
                password = nexusP
            }
        }
    }
}

```


### Pipeline


gradle publish

```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
           
             git 'https://github.com/VSVDEv/micro_gr.git'
                sh "ls -ll"
            }
        }
       
        stage('Deploy') {
            steps {
               echo "*****************Start deploy"
               sh "gradle publish"
            }
        }
    }
}
```

[Content](#content)


## Docker



1. repo - create - docker(hosted)
http -define port
enable docker v1 api
- create


http://100.0.0.16:8081/repository/dock/
5555


2. Nexus settings -> realms: add "Docker bearer token realm"

3. images

Maven image

```Dockerfile
FROM adoptopenjdk:11-jre-hotspot
EXPOSE 8080
EXPOSE 5000
ADD target/micro.jar micro.jar
ENTRYPOINT ["java", "-jar", "/micro.jar"]
```


docker build -t micro:1 .


Gradle image

```Dockerfile
FROM openjdk:11
ADD build/libs/*.jar  ./
EXPOSE 8888
ENTRYPOINT ["java","-jar","/micro_gr.jar"]
```
archivesBaseName = artifact

docker build -t micro_gr:3 .





### Configure docker on master node

connect to vm with docker and build image

```sh
cd /etc/docker
sudo nano daemon.json
```

paste:
{
"insecure-registries" : ["host:port"]
}




```json
{
"insecure-registries" : ["100.0.0.16:5555", "100.0.0.16:7777"]
}

```

```sh
sudo systemctl restart docker

<docker login -u username -p password host:port>

docker login -u jenk -p 123 100.0.0.16:5555
docker login -u jenk -p 123 100.0.0.16:7777
docker login 100.0.0.16:5555 --username jenk --password 123
```




http://100.0.0.16:8081/repository/dock-group/
7777




### Pipelines

```groovy

pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
           
             git 'https://github.com/VSVDEv/micro.git'
                sh "ls -ll"
            }
        }
       
        stage('maven package') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"

            }
        }
        stage('docker build') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"
               sh "docker build -t micro:1 ."
            }
        }
          stage('docker deploy') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"
               sh "docker tag micro:1 100.0.0.16:5555/micro:latest"
               sh "docker push 100.0.0.16:5555/micro:1"
            }
        }
    }
}

```


pull image


```groovy

pipeline {
    agent any
    stages {

          stage('docker pull') {
            steps {
               echo "*****************Start deploy"
               
               sh "docker pull 100.0.0.16:7777/nginx"
               sh "docker images"
            }
        }
    }
}

```

## If no basic auth

manage jenkins -> credentials -> add -> username and password -> global, paste username and password and add id"nexHub"

```groovy
pipeline {
    agent any
environment{
NEXUSHUB = credentials('nexHub')
}
 stage('docker pull') {
            steps {
               echo "*****************Start pull"
              sh "docker login -u $NEXUSHUB_USR -p $NEXUSHUB_PSW 100.0.0.16:7777"
               sh "docker pull 100.0.0.16:7777/httpd"
               sh "docker images"
            }
        }
}
```


```groovy
pipeline {
    agent any

    environment{
         NEXUSHUB = credentials('nexHub')
       }

    stages {
        stage('Clone') {
            steps {
           
             git 'https://github.com/VSVDEv/micro.git'
                sh "ls -ll"
            }
        }
       
        stage('maven package') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"

            }
        }
        stage('docker build') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"
               sh "docker build -t micro:5 ."
            }
        }
          stage('docker deploy') {
            steps {
               echo "*****************Start deploy"
               sh "mvn package"
               sh "docker tag micro:5 100.0.0.16:5555/micro:5"
               sh "docker login -u $NEXUSHUB_USR -p $NEXUSHUB_PSW 100.0.0.16:5555"
               sh "docker push 100.0.0.16:5555/micro:5"
            }
        }
    }
}

```

[Content](#content)


## Basic settings.xml example

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<!--
 | This is the configuration file for Maven. It can be specified at two levels:
 |
 |  1. User Level. This settings.xml file provides configuration for a single user,
 |                 and is normally provided in ${user.home}/.m2/settings.xml.
 |
 |                 NOTE: This location can be overridden with the CLI option:
 |
 |                 -s /path/to/user/settings.xml
 |
 |  2. Global Level. This settings.xml file provides configuration for all Maven
 |                 users on a machine (assuming they're all using the same Maven
 |                 installation). It's normally provided in
 |                 ${maven.conf}/settings.xml.
 |
 |                 NOTE: This location can be overridden with the CLI option:
 |
 |                 -gs /path/to/global/settings.xml
 |
 | The sections in this sample file are intended to give you a running start at
 | getting the most out of your Maven installation. Where appropriate, the default
 | values (values used when the setting is not specified) are provided.
 |
 |-->
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
  <!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/path/to/local/repo</localRepository>
  -->

  <!-- interactiveMode
   | This will determine whether maven prompts you when it needs input. If set to false,
   | maven will use a sensible default value, perhaps based on some other setting, for
   | the parameter in question.
   |
   | Default: true
  <interactiveMode>true</interactiveMode>
  -->

  <!-- offline
   | Determines whether maven should attempt to connect to the network when executing a build.
   | This will have an effect on artifact downloads, artifact deployment, and others.
   |
   | Default: false
  <offline>false</offline>
  -->

  <!-- pluginGroups
   | This is a list of additional group identifiers that will be searched when resolving plugins by their prefix, i.e.
   | when invoking a command line like "mvn prefix:goal". Maven will automatically add the group identifiers
   | "org.apache.maven.plugins" and "org.codehaus.mojo" if these are not already contained in the list.
   |-->
  <pluginGroups>
    <!-- pluginGroup
     | Specifies a further group identifier to use for plugin lookup.
    <pluginGroup>com.your.plugins</pluginGroup>
    -->
  </pluginGroups>

  <!-- TODO Since when can proxies be selected as depicted? -->
  <!-- proxies
   | This is a list of proxies which can be used on this machine to connect to the network.
   | Unless otherwise specified (by system property or command-line switch), the first proxy
   | specification in this list marked as active will be used.
   |-->
  <proxies>
    <!-- proxy
     | Specification for one proxy, to be used in connecting to the network.
     |
    <proxy>
      <id>optional</id>
      <active>true</active>
      <protocol>http</protocol>
      <username>proxyuser</username>
      <password>proxypass</password>
      <host>proxy.host.net</host>
      <port>80</port>
      <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
    </proxy>
    -->
  </proxies>

  <!-- servers
   | This is a list of authentication profiles, keyed by the server-id used within the system.
   | Authentication profiles can be used whenever maven must make a connection to a remote server.
   |-->
  <servers>
    
	<server>
      <id>nexus</id>
      <username>developer</username>
      <password>123</password>
    </server>
	
	<!-- server
     | Specifies the authentication information to use when connecting to a particular server, identified by
     | a unique name within the system (referred to by the 'id' attribute below).
     |
     | NOTE: You should either specify username/password OR privateKey/passphrase, since these pairings are
     |       used together.
     |
    <server>
      <id>deploymentRepo</id>
      <username>repouser</username>
      <password>repopwd</password>
    </server>
    -->

    <!-- Another sample, using keys to authenticate.
    <server>
      <id>siteServer</id>
      <privateKey>/path/to/private/key</privateKey>
      <passphrase>optional; leave empty if not used.</passphrase>
    </server>
    -->
  </servers>

  <!-- mirrors
   | This is a list of mirrors to be used in downloading artifacts from remote repositories.
   |
   | It works like this: a POM may declare a repository to use in resolving certain artifacts.
   | However, this repository may have problems with heavy traffic at times, so people have mirrored
   | it to several places.
   |
   | That repository definition will have a unique id, so we can create a mirror reference for that
   | repository, to be used as an alternate download site. The mirror site will be the preferred
   | server for that repository.
   |-->
  <mirrors>
    <!-- mirror
     | Specifies a repository mirror site to use instead of a given repository. The repository that
     | this mirror serves has an ID that matches the mirrorOf element of this mirror. IDs are used
     | for inheritance and direct lookup purposes, and must be unique across the set of mirrors.
     |
    <mirror>
      <id>mirrorId</id>
      <mirrorOf>repositoryId</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://my.repository.com/repo/path</url>
    </mirror>
     -->
    <mirror>
      <id>maven-default-http-blocker</id>
      <mirrorOf>external:http:*</mirrorOf>
      <name>Pseudo repository to mirror external repositories initially using HTTP.</name>
      <url>http://0.0.0.0/</url>
      <blocked>true</blocked>
    </mirror>
  </mirrors>

  <!-- profiles
   | This is a list of profiles which can be activated in a variety of ways, and which can modify
   | the build process. Profiles provided in the settings.xml are intended to provide local machine-
   | specific paths and repository locations which allow the build to work in the local environment.
   |
   | For example, if you have an integration testing plugin - like cactus - that needs to know where
   | your Tomcat instance is installed, you can provide a variable here such that the variable is
   | dereferenced during the build process to configure the cactus plugin.
   |
   | As noted above, profiles can be activated in a variety of ways. One way - the activeProfiles
   | section of this document (settings.xml) - will be discussed later. Another way essentially
   | relies on the detection of a property, either matching a particular value for the property,
   | or merely testing its existence. Profiles can also be activated by JDK version prefix, where a
   | value of '1.4' might activate a profile when the build is executed on a JDK version of '1.4.2_07'.
   | Finally, the list of active profiles can be specified directly from the command line.
   |
   | NOTE: For profiles defined in the settings.xml, you are restricted to specifying only artifact
   |       repositories, plugin repositories, and free-form properties to be used as configuration
   |       variables for plugins in the POM.
   |
   |-->
  <profiles>
    <!-- profile
     | Specifies a set of introductions to the build process, to be activated using one or more of the
     | mechanisms described above. For inheritance purposes, and to activate profiles via <activatedProfiles/>
     | or the command line, profiles have to have an ID that is unique.
     |
     | An encouraged best practice for profile identification is to use a consistent naming convention
     | for profiles, such as 'env-dev', 'env-test', 'env-production', 'user-jdcasey', 'user-brett', etc.
     | This will make it more intuitive to understand what the set of introduced profiles is attempting
     | to accomplish, particularly when you only have a list of profile id's for debug.
     |
     | This profile example uses the JDK version to trigger activation, and provides a JDK-specific repo.
    <profile>
      <id>jdk-1.4</id>

      <activation>
        <jdk>1.4</jdk>
      </activation>

      <repositories>
        <repository>
          <id>jdk14</id>
          <name>Repository for JDK 1.4 builds</name>
          <url>http://www.myhost.com/maven/jdk14</url>
          <layout>default</layout>
          <snapshotPolicy>always</snapshotPolicy>
        </repository>
      </repositories>
    </profile>
    -->

    <!--
     | Here is another profile, activated by the property 'target-env' with a value of 'dev', which
     | provides a specific path to the Tomcat instance. To use this, your plugin configuration might
     | hypothetically look like:
     |
     | ...
     | <plugin>
     |   <groupId>org.myco.myplugins</groupId>
     |   <artifactId>myplugin</artifactId>
     |
     |   <configuration>
     |     <tomcatLocation>${tomcatPath}</tomcatLocation>
     |   </configuration>
     | </plugin>
     | ...
     |
     | NOTE: If you just wanted to inject this configuration whenever someone set 'target-env' to
     |       anything, you could just leave off the <value/> inside the activation-property.
     |
    <profile>
      <id>env-dev</id>

      <activation>
        <property>
          <name>target-env</name>
          <value>dev</value>
        </property>
      </activation>

      <properties>
        <tomcatPath>/path/to/tomcat/instance</tomcatPath>
      </properties>
    </profile>
    -->
  </profiles>

  <!-- activeProfiles
   | List of profiles that are active for all builds.
   |
  <activeProfiles>
    <activeProfile>alwaysActiveProfile</activeProfile>
    <activeProfile>anotherAlwaysActiveProfile</activeProfile>
  </activeProfiles>
  -->
</settings>


```

[Content](#content)