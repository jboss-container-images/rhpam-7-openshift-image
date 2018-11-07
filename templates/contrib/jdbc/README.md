# Build JDBC Driver images

This repository provide a common repository for building JDBC Driver images to extend existing JBoss EAP Openshift images using S2I.

Implemented driver configurations (JDBC Drivers are NOT included):

| Database  | DB Version         | JDBC Driver                                   |
|-----------|--------------------|-----------------------------------------------|
| IBM DB2   | 10.5               | db2jcc4-10.5.jar                              |
| Derby     | 10.12.1.1          | derby-10.12.1.1.jar, derbyclient-10.12.1.1.jar|
| MariaDB   | 10.2               | mariadb-java-client-2.2.5.jar                 |
| MS SQL    | 2016               | sqljdbc4-4.0.jar                              |
| Oracle DB | 12c R1, 12c R1 RAC | ojdbc7-12.1.0.1.jar                           |
| Sybase    | 16.0               | jconn4-16.0_PL05.jar                          |

## Build a driver image of your choice

### Drivers publicly available

If a driver can be publicly downloaded it has a default value for the ARTIFACT_MVN_REPO argument

```bash
# Build mariadb using a tag with the version
$ docker build -f mariadb-driver-image/Dockerfile -t mariadb-driver-image:12.2 .
```

### Drivers not publicly available

If a driver cannot be publicly downloaded it is required to provide a value for the ARTIFACT_MVN_REPO argument that might point to a local file or a private Maven repository

```bash
# Local path. e.g. ./drivers/com/sybase/jconn4/16.0_PL05/jconn4-16.0_PL05.jar
$ docker build -f sybase-driver-image/Dockerfile --build-args ARTIFACT_MVN_REPO=drivers -t sybase-driver-image:16.0_PL05 .

# Private Maven Repository
$ docker build sybase-driver-image --build-args ARTIFACT_MVN_REPO=https://mvn-repo.example.com/nexus/content/groups/public -t sybase-driver-image:16.0_PL05 .
```

## The build.sh script

The `build.sh` script is customized for Red Hat Process Automation Manager (RHPAM) KIE Server
