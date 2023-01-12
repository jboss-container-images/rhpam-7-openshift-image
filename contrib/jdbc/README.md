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


# TODO update it after the compatibility matrix is published
For more information, please visit the IBM BAMOE [compatibility matrix](https://access.redhat.com/articles/3405381#RHPAM713).


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

These extension images were designed to be used with IBM BAMOE images but can be used with any other image since it supports
s2i builds, see this [link](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html/red_hat_jboss_enterprise_application_platform_for_openshift/configuring_eap_openshift_image#Build-Extensions-Project-Artifacts) for more information.

To deploy it using any of the extension images, follow the steps below:

- create a new namespace:

  ```bash
    oc new-project ibm-bamoe-externaldb
  ```

- verify if the IBM BAMOE 8.0 imagestreams are available:

  ```bash
    oc get imagestream -n openshift | grep bamoe | grep 8.0
  ```

- if the command above does not return any result the imagestreams must be installed, to do this execute the following command:

  ```bash
    oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.x-blue/ibm-bamoe8-image-streams.yaml
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
      oc create -f my-image-stream.yaml
      ```

  - import directly on OpenShift:

      ```bash
      oc import-image jboss-kie-oracle-extension-openshift-image:12cR1 --from=registry/project/jboss-kie-oracle-extension-openshift-image:12cR1 --confirm
      ```

  - push the image directly to the OpenShift registry: [Accessing the registry](https://docs.openshift.com/container-platform/3.11/install_config/registry/accessing_registry.html#access)



### Let's install
In order to create a Kie Server deployment using  your own JDBC extension driver images you can use the Business Automation Operator, the OpenShift web console and the wizard installer.

All the steps needed are documented [here](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.13/html/deploying_red_hat_process_automation_manager_on_red_hat_openshift_container_platform/operator-con_openshift-operator#operator-deploy-kieserver-proc_openshift-operator) 
and you have to pay attention to steps 13 and 17.

Note: if you are going to use one of the ready extension images (mysql, mariadb or postgresql) at step 17 you can use
[this](extension-image-streams.yaml) imagestream file.

At this point we are ready to create a Kie Server deployment using the extension driver and the Operator, simply creating a new KieApp with the configuration that you will build following the instructions in the documentation using the wizard installer. 

If you find any issue feel free to drop an email to bsig-cloud@redhat.com or fill an [issue](https://issues.jboss.org/projects/RHPAM)
