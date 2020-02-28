# JBoss KIE JDBC Driver Extension Images

This repo provide a easy way to build your own JDBC extension driver images to use within Red Hat Process Automation Manager images
on OpenShift.

#### What is a extension image?

The extension image is basically a minimal image that include all the files needed to configure a jdbc driver
in the image used for deployment.

It adds a extra layer on top of the base image which contains:

- the jdbc driver
    - needs to respect the JBoss EAP module structure: i.e:
            */extensions/modules/org/postgresql96/main/*
- the install.properties which contains the JBoss module information, this file is populated during the build image
 , [here](modules/kie-custom-jdbc-driver/added/base_install.properties) you can find the base file used.

- the install.sh script which is responsible to configure the JBoss module: [install.sh](modules/kie-custom-jdbc-driver/added/install.sh)


## Before begin

##### Pre requisites:

To interact with this repo you should install the CEKit 3.0.1:

- https://docs.cekit.io/en/latest/


The drivers images are based on the supported configurations for Red Hat Process Automation Manager, which are:

| Database    | DB Version              | JDBC Driver jar/version         |
|-------------|-------------------------|---------------------------------|
| IBM DB2     | 11.1                    | jcc-11.1.4.4.jar                |
| MariaDB     | 10.2                    | mariadb-java-client-2.3.0.jar   |
| MS SQL      | 2014,2016               | mssql-jdbc-7.2.2.jre11.jar       |
| Oracle DB   | 12c RAC                 | example: ojdbc7.jar             |
| MySQL       | 5.7                     | mysql-connector-java-8.0.12.jar |
| PosgtgreSQL | 10.1, 10.1 Enterprise   | postgresql-42.2.5.jar           |
| Sybase      | 16.0                    | jconn4-16.0_PL05.jar            |


For more information, please visit the RHPAM [compatibility matrix](https://access.redhat.com/articles/3405381#RHPAM74).

#### Extension Images

There is a few extension images public available on quay.io:


##### MySQL:

Driver version: 8.0.12

```bash
quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12
```

##### MariaDB:

Driver version: 2.3.0

```bash
quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.3.0
```

##### PostgreSQL:

Driver version: 42.2.5

```bash
quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5
```

You can import these images into you OpenShift instance using the extension-image-streams.yaml with the following command:

```bash
$ oc create -f extension-image-streams.yaml -m <NAME_SPACE>
```

The namespace is the project that you are working on OpenShift, or, you can also choose a common namespace to install these imagestreams, like `openshift`


#### Building a extension image

All you need to do is install cekit2 and execute the `make build` command specifying the image you want to build, i.e.:

```bash
$ make build mysql
```
This command will build the mysql extension image with the jdbc driver version 8.0.12.

The artifacts to build the db2, mysql, mariadb, postgresql and mssql are available on maven central.


See the examples below on how to build the other extension images:


##### DB2
```bash
$ make build db2
```

If you want to specify a custom artifact, use the *artifact* and *version* variables within make command:

```bash
$ make build db2 artifact=/tmp/db2-jdbc-driver.jar version=10.1
```


##### mysql
```bash
$ make build mysql
```


##### mariadb

```bash
$ make build mariadb
```


##### postgresql
```bash
$ make build postgresql
```


##### mssql
```bash
$ make build mssql
```

##### oracle

Oracle extension image requires you to provide the jdbc jar:

```bash
$ make build oracle artifact=/tmp/ojdbc7.jar version=7.0
```

##### DB2

DB2 extension image requires you to provide the jdbc jar:

```bash
$ make build db2 artifact=/tmp/db2jcc4.jar version=10.2
```

##### sybase

Sybase extension image requires you to provide the jdbc jar:

```bash
$ make build sybase artifact=/tmp/jconn4-16.0_PL05.jar version=16.0_PL05
```


After you build your extension image you can:

- Push the image to some internal/public registry and import the image on OpenShift using:
    - imagestream:
        ```yaml
          ---
          kind: List
          apiVersion: v1
          metadata:
            name: jboss-kie-jdbc-extensions-image
            annotations:
              description: ImageStream definition for jdbc driver extension
          items:
          - kind: ImageStream
            apiVersion: v1
            metadata:
              name: jboss-kie-oracle-extension-openshift-image
              annotations:
                openshift.io/display-name: oracle driver extension
            spec:
              dockerImageRepository: some.public.registry/projectname/jboss-kie-oracle-extension-openshift-image
              tags:
              - name: '12cR1'
                annotations:
                  description: JBoss KIE custom mysql jdbc extension image, recommended version driver.
                  tags: oracle,extension,jdbc,driver
                  version: '12cR1'
        ```

        then import it on OpenShift:
        ```bash
        $ oc create -f my-image-stream.yaml
        ```

    - import directly on OpenShift:
        ```bash
        $ oc import-image jboss-kie-oracle-extension-openshift-image:12cR1 --from=registry/project/jboss-kie-oracle-extension-openshift-image:12cR1 --confirm
        ```

    - push the image directly to the OpenShift registry: https://docs.openshift.com/container-platform/3.11/install_config/registry/accessing_registry.html#access


### How to use the extension images

These extension images were designed to be used with RHPAM images but can be used with any other image since it supports
s2i builds, see this [link](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html/red_hat_jboss_enterprise_application_platform_for_openshift/configuring_eap_openshift_image#Build-Extensions-Project-Artifacts) for more information.

We provide a external database [application template](../../rhpam77-kieserver-externaldb.yaml) ready to use the extension images.

To deploy it using any of the extension images, follow the steps below:

- create a new namespace:
  ```bash
    $ oc new-project rhpam-externaldb
  ```

Note that, by default all application templates and imagestreams are installed under the **openshift** namespace.

- verify if the external-db template is available on the **openshift** namespace:
  ```bash
    $ oc get templates -n openshift | grep rhpam43-kieserver-externaldb
  ```

- if it does not return the template, you will need to install the template on OpenShift, the recommend namespace
to install it is **openshift** but feel free to install it on the preferred namespace.
   ```bash
     $ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/templates/rhpam77-kieserver-externaldb.yaml
   ```

- verify if the RHPAM 7.7 imagestreams are available:
  ```bash
    $ oc get imagestream -n openshift | grep rhpam | grep 7.7
  ```

- if the command above does not return any result the imagestreams must be installed, to do this execute the following command:
  ```bash
    $ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/rhpam77-image-streams.yaml
  ```

The externaldb template requires a secret containing ssl certificates, we provide [this certificate](../../../example-app-secret-template.yaml)
as example.

Let's install:

```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/example-app-secret-template.yaml
$ oc new-app example-app-secret
```

Optional, if you are going to use one of the ready extension images (mysql, mariadb or postgresql) import
[this](extension-image-streams.yaml) imagestream:

```bash
$ oc create -f extension-image-streams.yaml
```

At this point we are ready to create an kieserver application using the extension driver:
Note that, the driver name can be found in the respective install-{DB}. properties file, i.e. [mariadb](modules/kie-custom-jdbc-driver/added/install-mariadb.properties)

To create a new app using a extension image, you can go through the OpenShift web console and fill all the needed fields or
create it using command line:

```bash
$ oc new-app rhpam77-kieserver-externaldb \
  -p MAVEN_REPO_URL=http://some.mave.repo \
  -p IMAGE_STREAM_NAMESPACE=rhpam-externaldb \
  -p CREDENTIALS_SECRET=rhpam-credentials \
  -p KIE_SERVER_EXTERNALDB_DIALECT=org.jbpm.persistence.jpa.hibernate.DisabledFollowOnLockOracle10gDialect \
  -p KIE_SERVER_EXTERNALDB_JNDI=java:jboss/datasources/jbpmDS \
  -p KIE_SERVER_EXTERNALDB_URL=jdbc:oracle:thin:@<ORACLE_DB_ADDRESS>:1521:bpms \
  -p KIE_SERVER_EXTERNALDB_USER=<USERNAME> \
  -p KIE_SERVER_EXTERNALDB_PWD=<PASSWORD> \
  -p KIE_SERVER_EXTERNALDB_DRIVER=oracle \
  -p KIE_SERVER_EXTERNALDB_CONNECTION_CHECKER=org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker \
  -p KIE_SERVER_EXTERNALDB_EXCEPTION_SORTER=org.jboss.jca.adapters.jdbc.extensions.oracle.OracleExceptionSorter  \
  -p EXTENSIONS_IMAGE=jboss-kie-oracle-extension-openshift-image:12cR1 \
  -p EXTENSIONS_IMAGE_NAMESPACE=rhpam-externaldb \
  -p KIE_SERVER_HTTPS_SECRET=businesscentral-app-secret
```
Remember to update the parameters according your needs.

If you find any issue feel free to drop an email to bsig-cloud@redhat.com or fill an [issue](https://issues.jboss.org/projects/RHPAM)
