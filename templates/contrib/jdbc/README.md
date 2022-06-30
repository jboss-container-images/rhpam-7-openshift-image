# JBoss KIE JDBC Driver Extension Images

This repo provides an easy way to build your own JDBC extension driver images to use within IBM Business Automation Manager Open Editions images
on OpenShift.

## About the extension image

The extension image is basically a minimal image that include all the files needed to configure a jdbc driver
in the image used for deployment.

It adds a extra layer on top of the base image which contains:

- the jdbc driver
  - needs to respect the JBoss EAP module structure: i.e:
            */extensions/modules/org/postgresql96/main/*
- the install.properties which contains the JBoss module information, this file is populated during the build image
 , [here](cekit/modules/kie-custom-jdbc-driver/added/base_install.properties) you can find the base file used.

- the install.sh script which is responsible to configure the JBoss module: [install.sh](modules/kie-custom-jdbc-driver/added/install.sh)


The drivers images are based on the supported configurations for IBM Business Automation Manager Open Editions, which are:


| Database    | DB Version                                     | JDBC Driver jar/version         |
|-------------|------------------------------------------------|---------------------------------|
| IBM DB2     | 11.1                                           | jcc-11.1.4.4.jar                |
| MariaDB     | 10.2                                           | mariadb-java-client-2.3.0.jar   |
| MS SQL      | 2014,2016. 2017                                | mssql-jdbc-7.2.2.jre11.jar      |
| Oracle DB   | 12c RAC, 19c RAC                               | example: ojdbc7.jar             |
| MySQL       | 5.7, 8.0                                       | mysql-connector-java-8.0.12.jar |
| PosgtgreSQL | 10.1, 11.5, 10.1 Enterprise, 11.6 Enterprise   | postgresql-42.2.5.jar           |
| Sybase      | 16.0                                           | jconn4-16.0_PL05.jar            |

For more information, please visit the RHPAM [compatibility matrix](https://access.redhat.com/articles/3405381#RHPAM713).


## Extension Images

There is a few extension images public available on quay.io:

### MySQL

Driver version: 8.0.12

```bash
quay.io/kiegroup/jboss-kie-mysql-extension-openshift-image:8.0.12
```

### MariaDB

Driver version: 2.3.0

```bash
quay.io/kiegroup/jboss-kie-mariadb-extension-openshift-image:2.3.0
```

### PostgreSQL

Driver version: 42.2.5

```bash
quay.io/kiegroup/jboss-kie-postgresql-extension-openshift-image:42.2.5
```

You can import these images into your OpenShift instance using the extension-image-streams.yaml with the following command:

```bash
oc create -f extension-image-streams.yaml -m <NAME_SPACE>
```

The namespace is the project that you are working on OpenShift, or, you can also choose a common namespace to install these imagestreams, like `openshift`

## Building an extension image

There is two possible ways to build an extension image:

- Using [CeKit](cekit/README.md): This is the preferred way as it assures that the built images will contain the expected files
- Using [Dockerfile](legacy/README.md): legacy way that we had in the past, notice that, the scripts are provided as it is, feel free to use
it as a point of start and any issue or wrong configuration can lead on issues while using it with the Kie Server image.

## How to use the extension images

These extension images were designed to be used with RHPAM images but can be used with any other image since it supports
s2i builds, see this [link](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html/red_hat_jboss_enterprise_application_platform_for_openshift/configuring_eap_openshift_image#Build-Extensions-Project-Artifacts) for more information.

We provide an external database [application template](../../rhpam713-kieserver-externaldb.yaml) ready to use the extension images.

To deploy it using any of the extension images, follow the steps below:

- create a new namespace:

  ```bash
    oc new-project rhpam-externaldb
  ```

Note that, by default all application templates and imagestreams are installed under the **openshift** namespace.

- verify if the external-db template is available on the **openshift** namespace:

  ```bash
    oc get templates -n openshift | grep rhpam713-kieserver-externaldb
  ```

- if it does not return the template, you will need to install the template on OpenShift, the recommended namespace
to install it is **openshift** but feel free to install it on the preferred namespace.

   ```bash
     oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/templates/rhpam713-kieserver-externaldb.yaml
   ```

- verify if the RHPAM 7.13 imagestreams are available:

  ```bash
    oc get imagestream -n openshift | grep rhpam | grep 7.13
  ```

- if the command above does not return any result the imagestreams must be installed, to do this execute the following command:

  ```bash
    oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/rhpam713-image-streams.yaml
  ```

The externaldb template requires a secret containing ssl certificates, we provide [this certificate](../../../example-app-secret-template.yaml)
as example, please do not use this in production.


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
      oc create -f my-image-stream.yaml
      ```

  - import directly on OpenShift:

      ```bash
      oc import-image jboss-kie-oracle-extension-openshift-image:12cR1 --from=registry/project/jboss-kie-oracle-extension-openshift-image:12cR1 --confirm
      ```

  - push the image directly to the OpenShift registry: [Accessing the registry](https://docs.openshift.com/container-platform/3.11/install_config/registry/accessing_registry.html#access)



### Let's install

```bash
oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/example-app-secret-template.yaml
oc new-app example-app-secret
```

Optional, if you are going to use one of the ready extension images (mysql, mariadb or postgresql) import
[this](extension-image-streams.yaml) imagestream:

```bash
oc create -f extension-image-streams.yaml
```

At this point we are ready to create a Kie Server deployment using the extension driver:
Note that, the driver name can be found in the respective install-{DB}. properties file, i.e. [mariadb](modules/kie-custom-jdbc-driver/added/install-mariadb.properties)

To create a new app using a extension image, you can go through the OpenShift web console and fill all the needed fields or
create it using command line:

```bash
$ oc new-app rhpam713-kieserver-externaldb \
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
