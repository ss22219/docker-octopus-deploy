This image can be used to bring up an instance of [Octopus Deploy](https://octopus.com) in a container.

**Please note that by using the Octopus Deploy Server Container you agree to the Octopus Deploy [EULA](https://octopus.com/legal/customer-agreement).**

# Quick reference
* **Where to get help:** [Troubleshooting Octopus Server in a container](https://octopus.com/docs/installation/octopus-in-container/troubleshooting-octopus-server-in-a-container), [Octopus Deploy Documentation](https://octopus.com/docs), [Octopus Deploy Community Slack](https://octopus.com/slack), [Octopus Support](https://octopus.com/support)
* **Maintained By:** [Octopus Deploy](https://github.com/OctopusDeploy)

# Pre-Requisites

When running Docker from a Windows Machine, make sure you've enabled the containers feature:

```
Enable-WindowsOptionalFeature -Online -FeatureName containers –All
```

If you want to run with [Hyper-V isolation](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container), enable Hyper-V as well:

```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All
```

# Usage - Windows Container #

Note: When running Windows Containers, please ensure you have Docker set to [use Windows Containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers).

When mounting a volume, please ensure the folder exists on the host machine before creating the container.

From your windows machine run:

```powershell
docker run --name OctopusDeploy --publish 1322:8080 --env ACCEPT_EULA="Y" --env DB_CONNECTION_STRING="..." --volume "C:\Octopus\Data:C:\Octopus" octopusdeploy/octopusdeploy
```

Once the container is ready, Octopus Server can be accessed on port http://localhost:1322.

# Usage - Linux Container #

**Octopus Deploy Linux Containers are part of our Early Access Program (EAP) and may contain bugs or be unstable.**

Note: When using Linux containers on a Windows machine, please ensure you have [switched to Linux Containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers).

Run the following to create a Octopus Server Linux Container:

```bash
$ docker run --name OctopusDeploy --publish 1322:8080 --env ACCEPT_EULA="Y" --env DB_CONNECTION_STRING="..." octopusdeploy/octopusdeploy
```

Once the container is ready, Octopus Server can be accessed on port http://localhost:1322.

## Docker Compose ##

A docker compose file is available for linux which will create a Microsoft SQL Server container and an Octopus Deploy Server container ready for use. Please note that data stored in the Microsoft SQL Server container will be lost unless you use external storage. 

Usage of this docker-compose.yml file requires your acceptance of the Microsoft SQL Server [EULA](https://hub.docker.com/r/microsoft/mssql-server-windows-express/).

To use the docker compose file, create both the docker-compose.yml and the .env file below in a folder together and run `docker-compose up`

It is highly recommended that you change the password for your database user and for the Octopus Server admin user. When changing the database password, be sure to update it in `SA_PASSWORD` and the `DB_CONNECTION_STRING`. 

### docker-compose.yml ###
```yaml
version: '3'
services:
   db:
    image: ${SQL_IMAGE}
    environment:
      SA_PASSWORD: ${SA_PASSWORD}
      ACCEPT_EULA: ${ACCEPT_EULA}
    ports:
      - 1401:1433
    healthcheck:
      test: [ "CMD", "/opt/mssql-tools/bin/sqlcmd", "-U", "sa", "-P", "${SA_PASSWORD}", "-Q", "select 1"]
      interval: 10s
      retries: 10
    volumes:
      - sqlvolume:/var/opt/mssql
   octopus-server:
    image: octopusdeploy/octopusdeploy:${OCTOPUS_SERVER_TAG}
    privileged: ${PRIVILEGED}
    user: ${USER}
    environment:
      ACCEPT_EULA: ${ACCEPT_OCTOPUS_EULA}
      OCTOPUS_SERVER_NODE_NAME: ${OCTOPUS_SERVER_NODE_NAME}
      DB_CONNECTION_STRING: ${DB_CONNECTION_STRING}
      ADMIN_USERNAME: ${ADMIN_USERNAME}
      ADMIN_PASSWORD: ${ADMIN_PASSWORD}
      ADMIN_EMAIL: ${ADMIN_EMAIL}
      OCTOPUS_SERVER_BASE64_LICENSE: ${OCTOPUS_SERVER_BASE64_LICENSE}
      MASTER_KEY: ${MASTER_KEY}
      ADMIN_API_KEY: ${ADMIN_API_KEY}
      DISABLE_DIND: ${DISABLE_DIND}
    ports:
      - 8080:8080
      - 11111:10943
    depends_on:
      - db
    volumes:
      - repository:/repository
      - artifacts:/artifacts
      - taskLogs:/taskLogs
      - cache:/cache
      - import:/import
volumes:
  repository:
  artifacts:
  taskLogs:
  cache:
  import:
  sqlvolume:
```

### .env ###

```
# Define the password for the SQL database. This also must be set in the DB_CONNECTION_STRING value.
SA_PASSWORD=

# Tag for the Octopus Deploy Server image. Use "latest" to pull the latest image or specify a specific tag
OCTOPUS_SERVER_TAG=latest

# Sql Server image. Set this variable to the version you wish to use. Default is to use the latest.
SQL_IMAGE=mcr.microsoft.com/mssql/server

# The default created user username for login to the Octopus Server
ADMIN_USERNAME=

# It is highly recommended this value is changed as it's the default user password for login to the Octopus Server
ADMIN_PASSWORD=

# Email associated with the default created user. If empty will default to octopus@example.local
ADMIN_EMAIL=

# Accept the Microsoft Sql Server Eula found here: https://hub.docker.com/r/microsoft/mssql-server-windows-express/
ACCEPT_EULA=Y

# Use of this Image means you must accept the Octopus Deploy Eula found here: https://octopus.com/company/legal
ACCEPT_OCTOPUS_EULA=Y

# Unique Server Node Name - If left empty will default to the machine Name
OCTOPUS_SERVER_NODE_NAME=

# Database Connection String. If using database in sql server container, it is highly recommended to change the password.
DB_CONNECTION_STRING=Server=db,1433;Database=OctopusDeploy;User=sa;Password=THE_SA_PASSWORD_DEFINED_ABOVE

# Your License key for Octopus Deploy. If left empty, it will try and create a free license key for you
OCTOPUS_SERVER_BASE64_LICENSE=

# Octopus Deploy uses a master key for encryption of your databse. If you're using an external database that's already been setup for Octopus Deploy, you can supply the master key to use it. 
# If left blank, a new master key will be generated with the database creation.
# Create a new master key with the command: openssl rand 16 | base64
MASTER_KEY=

# The API Key to set for the administrator. If this is set and no password is provided then a service account user will be created. If this is set and a password is also set then a standard user will be created.
ADMIN_API_KEY=

# Docker-In-Docker is used to support worker container images. It can be disabled by setting DISABLE_DIND to Y.
# The container only requires the privileged setting if DISABLE_DIND is set to N.
DISABLE_DIND=Y
PRIVILEGED=false

# Octopus can be run either as the user root or as octopus.
USER=octopus
```


# Additional Environment Variables

The following can be passed as additional `--env` arguments when creating the docker container. The only required environment variables are `ACCEPT_EULA` and `DB_CONNECTION_STRING` with the following being optional:


`OCTOPUS_SERVER_NODE_NAME` - Unique Server Node Name. If left empty will default to the machine name.

`ADMIN_USERNAME` - Default admin username.

`ADMIN_PASSWORD` - Default admin password.

`ADMIN_EMAIL` - Default admin email.

`OCTOPUS_SERVER_BASE64_LICENSE` - Your License key for Octopus Deploy. If left empty, it will try and create a free license key for you.

`ADMIN_API_KEY` - The API Key to set for the administrator. If this is set and no password is provided then a service account user will be created. If this is set and a password is also set then a standard user will be created.

`MASTER_KEY` - Octopus Deploy uses a Master Key for encryption of your databse. If you're using an external database that's already been setup for Octopus Deploy, you can supply the master key to use it. If left blank, a new master key will be generated with the database creation. A new master key can be generated manually with the command `openssl rand 16 | base64`.

## A note on MasterKeys ##

Octopus makes use of MasterKeys for [security and encryption](http://docs.octopusdeploy.com/display/OD/Security+and+encryption). On Windows, when the container is first run, it will generate a new MasterKey and store it on the data volume supplied. On Linux, the MasterKey will be stored in /etc/Octopus. It uses this key to talk to the database, so if you want to keep the data in the database, please do not lose this key.

If using an existing database setup for Octopus Deploy Server, you can pass the MasterKey into `docker run` as an environment variable with `--env MASTER_KEY=XXX`.

# Additional Information #

* The default admin credentials are `admin` / `Passw0rd123`. This can (and should) be overridden by passing `--env ADMIN_USERNAME=XXX --env ADMIN_PASSWORD=YYY` or by setting the values in the .env file if using the docker compose file.
