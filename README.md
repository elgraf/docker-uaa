# UAA 

Docker container for the UAA server

Tested with `docker` version: `1.12.1`

## Docker Stats

```bash
❯❯❯ docker version

Client:
 Version:      1.12.1
 API version:  1.24
 Go version:   go1.7.1
 Git commit:   6f9534c
 Built:        Thu Sep  8 10:31:18 2016
 OS/Arch:      darwin/amd64

Server:
 Version:      1.12.1
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   23cf638
 Built:        Thu Aug 18 17:52:38 2016
 OS/Arch:      linux/amd64

```

## Running a postgresql container to store data

The sample `uaa.yml` configuration tells the UAA server to store its data in a postgresql database. If you change it to something else, then skip to the next chapter.

To easily create a postgresql database on your local dev environment, use Docker. The following command creates a local [postgresql container](https://registry.hub.docker.com/_/postgres/) with a default database called 'postgres' and a default user 'postgres'.

```
docker run -d --name uaa-db postgres
```

### Postgres.app (MacOSX only)

If you are using Postgres.app and would like to use a docker image to connect while keeping persistence the same, make sure you find out what version of Postgres.app is running and then type in: `docker pull postgres:$version`. If you want the latest, `$version` can be `latest`

NOTE: You will probably have to change your `pg_hba.conf` and `postgres.conf` files to listen on all addresses and be more liberal on connections.

Then:

```bash
docker run -d -v ~/Library/Application\ Support/Postgres/var-$VERSION/var/lib/postgresql/data --name uaa-db postgres:$VERSION
```


**WARNING**: Make sure you turn off Postgres.app before you run the docker command above, otherwise you may risk corrupting your data.

## Running the UAA server

To run the UAA server, first you'll need a configuration file. UAA accepts a YAML config file where the default clients and users can be defined among some other things, like where to store the data. You can find a basic configuration in the project repository. The default configuration stores data in a postgresql database whose connection parameters are defined in environment variables (that are automatically set when a database container is linked with the name *db*).

You will need to "mount" the war file that was generated as a result of the `./gradlew` command from [CloudFoundry's uaa](https://github.com/cloudfoundry/uaa).

```bash
docker run -d --link uaa-db:db -v $(pwd)/war:/tomcat/webapps uaa:1.0.0
```

This docker container reads the configuration file `uaa.yml` from the `/uaa` folder. The container can accept configuration files from an URL, or from a shared volume. To run a UAA server with a configuration file in a shared volume, run this command:

```bash
docker run -d --link uaa-db:db -v $(pwd)/war:/tomcat/webapps -v /tmp/uaa:/uaa uaa:1.0.0
```

If you are using boot2docker on OSX, host volume sharing only shares the host folder in boot2docker, so make sure your configuration is in boot2docker's `/tmp/uaa` folder.

To get the configuration from an URL:

```bash
docker run -d \
      --link uaa-db:db \
      -e UAA_CONFIG_URL=https://raw.githubusercontent.com/verygood-ops/docker-uaa/master/uaa.yml \
      -v $(pwd)/war:/tomcat/webapps \
      -v /tmp/uaa:/uaa \
      uaa:1.0.0
```

## Hacking

```bash
make 
```

Expected output:

```bash
❯❯❯ make
if [ ! -e apache-tomcat-8.0.28.tar.gz ]; then wget -q https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz; fi \
        && wget -qO- https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz.md5 | awk -F '[ *]+' -v P="$CWD/docker-uaa" '{ cmd="cd "P";md5 -r "$2; while ((cmd|getline result)>0) {}; close(cmd);  if ((result == $1" "$2) == 1) { exit 0 }; exit 1;}'
env COPY_EXTENDED_ATTRIBUTES_DISABLE=true COPYFILE_DISABLE=true \
                tar cvf base.tar --exclude '\._*' \
                        *.yml                           \
                        *.sh                            \
                        *.tar.gz
a dev.yml
a uaa.yml
a run.sh
a apache-tomcat-8.0.28.tar.gz
docker build -t uaa:1.0.0 --rm .
Sending build context to Docker daemon 18.29 MB
Step 1 : FROM anapsix/alpine-java:8_server-jre
 ---> 991c7eae32d6
Step 2 : MAINTAINER vgg
 ---> Using cache
 ---> fd174aa32883
Step 3 : ENV UAA_CONFIG_PATH /uaa CATALINA_HOME /tomcat
 ---> Using cache
 ---> 2abd6117d527
Step 4 : ADD ./base.tar /tmp
 ---> Using cache
 ---> 98d194a24aaf
Step 5 : RUN mv /tmp/run.sh /tmp/run.sh       && mkdir -p /tomcat /uaa            && mv /tmp/dev.yml /uaa/uaa.yml        && chmod +x /tmp/run.sh     && tar -xf /tmp/apache-tomcat-8.0.28.tar.gz -C /tomcat     && rm /tmp/apache-tomcat-8.0.28.tar.gz     && mv /tomcat/apache-tomcat-8.0.28/* /tomcat     && rm -fr /tomcat/webapps/*
 ---> Running in 3542cc3cb5d2
 ---> 24c414f796d7
Removing intermediate container 3542cc3cb5d2
Step 6 : VOLUME /tomcat/webapps/
 ---> Running in 1b96f787b4d9
 ---> b904232560fb
Removing intermediate container 1b96f787b4d9
Step 7 : EXPOSE 8080
 ---> Running in 44480779f88c
 ---> ce2fcd5bdcea
Removing intermediate container 44480779f88c
Step 8 : CMD /tmp/run.sh
 ---> Running in e4f66e8af637
 ---> b09c0c4f7b59
Removing intermediate container e4f66e8af637
Successfully built b09c0c4f7b59
```

Then run it as:

```bash
docker run -d --link uaa-db:db -v $(pwd)/war:/tomcat/webapps uaa:1.0.0
```