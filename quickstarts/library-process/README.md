## IBM Business Automation Manager Open Editions Kie Server Quickstart

Note that, this is the development branch, the target images might not be available here, instead you can look at the [released branch](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/7.13.x/quickstarts/library-process)

This quickstart is intend to be used with the [RHPAM Kie Server](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/main/kieserver) image.

## How to use it?

To deploy the Library Process demo you can use the [rhpam713-prod-immutable-kieserver](https://github.com/jboss-container-images/rhpam-7-openshift-image/blob/main/templates/rhpam713-prod-immutable-kieserver.yaml)

To deploy it on your OpenShift instance, just execute the following commands:

```bash
$ oc login https://<your_openshift_address>:<port>
```

```bash
$ oc new-project rhpam-kieserver
```

Make sure you have the RHPAM template installed in your OpenShift Instance:
```bash
$ oc get template rhpam713-prod-immutable-kieserver -n openshift
Error from server (NotFound): templates.template.openshift.io "rhpam713-prod-immutable-kieserver" not found
```

If you don't have it yet, just install it:

```bash
oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/templates/rhpam713-prod-immutable-kieserver.yaml -n openshift
template.template.openshift.io "rhpam713-prod-immutable-kieserver" created
```

For this template, we also need to install the secrets, which contain the certificates to configure https:
```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/example-app-secret-template.yaml
$ oc new-app example-app-secret -p SECRET_NAME=businesscentral-app-secret
```

Before proceed, make sure you have the RHDM imagestreams available under the 'openshift' namespace.

```bash
$ oc get imagestream rhpam-kieserver-rhel8 -n openshift | grep 7.13
Error from server (NotFound): imagestreams.image.openshift.io "rhpam-kieserver-rhel8" not found
```

 If the `rhpam-kieserver-rhel8` is not found, install it under the 'openshift' namespace:
 ```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/rhpam713-image-streams.yaml -n openshift
```

Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)


Deploy the `credentials secret` provided as example:

```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/main/example-credentials.yaml
secret/rhpam-credentials created
```

Default credential is `adminUser/RedHat`.

Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)

At this moment we are ready to instantiate the kieserver app:

```bash
$ oc new-app rhpam713-prod-immutable-kieserver \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=rhpam-kieserver-library=org.openshift.quickstarts:rhpam-kieserver-library:1.6.0-SNAPSHOT \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=main \
-p CONTEXT_DIR=quickstarts/library-process/library \
-p KIE_SERVER_HTTPS_SECRET=businesscentral-app-secret \
-p CREDENTIALS_SECRET=rhpam-credentials \
-p IMAGE_STREAM_NAMESPACE=openshift
```

Now you can deploy the [library-client](library-client) in the same or another project and test RHPAM Kie Server container.

To deploy the library-process client you can use the **eap73-basic-s2i** template and specify the above quickstart to be deployed. It should available in the OpenShift Catalog, 
if not, follow the steps described [here](https://github.com/jboss-container-images/jboss-eap-7-openshift-image/blob/eap73/README.adoc) to install the missing template. 

You might be required to import the EAP 7.3 imagestream as well:
```bash
$ oc replace -f https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/eap73/templates/eap73-image-stream.json -n openshift
```

```bash
$ oc new-app eap73-basic-s2i \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=main \
-p CONTEXT_DIR=quickstarts/library-process \
-p DATASOURCES=RHPAM \
-p RHPAM_DATABASE=rhpam \
-p RHPAM_DRIVER=h2 \
-p RHPAM_JNDI=java:jboss/datasources/rhpam \
-p RHPAM_USERNAME=sa \
-p RHPAM_PASSWORD=sa \
-p RHPAM_JTA=false \
-p RHPAM_NONXA=true \
-p RHPAM_URL="jdbc:h2:mem:rhpam;DB_CLOSE_DELAY=-1"
```


After the application is built, access the library process client app through the route created:

```bash
$ oc get routes eap-app
NAME      HOST/PORT                                         PATH      SERVICES   PORT      TERMINATION   WILDCARD
eap-app  eap-app-rhpam-kieserver.<your_openshift_suffix>               eap-app    <all>                   None
```

Note that this route should be resolvable.

And example of request would be something like this:

```bash
http://eap-app-rhpam-kieserver.<your_openshift_suffix>/library?command=runRemoteRest&protocol=http&host=myapp-kieserver&port=8080&username=adminUser&password=RedHat
```


### JMS integration outside OpenShift

This example allows you to test if your JMS setup is working properly and if you are able to perform JMS calls outside OpenShift
by using the *library-process* quickstart and this client to interact with Active MQ.

Before proceed, clone this repository.
Follow the steps described before to:
 - install the rhpam713-prod-immutable-kieserver-amq.yaml template in the current namespace
 - install the https secret
 - credentials secret
 - Make sure that the Active MQ 7.8 imagestream is available in the `openshift` namespace. 
   ```bash
   $ oc replace -n openshift --force  -f \
     https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/78-7.8.0.GA/amq-broker-7-image-streams.yaml
   ```
 - configure the Active MQ self-signed certificates, the steps can be found [here](https://access.redhat.com/documentation/en-us/red_hat_amq/2020.q4/html/deploying_amq_broker_on_openshift/deploying_broker-on-ocp-using-templates_broker-ocp#connecting-external-clients-to-template-based-brokers_broker-ocp)


After properly configuring the Active-MQ pre-requisites, deploy the Kie Server using the AMQ Application template:
To deploy the template execute the following command:

```bash
$ oc new-app rhpam713-prod-immutable-kieserver-amq \
-p KIE_SERVER_HTTPS_SECRET=businesscentral-app-secret \
-p CREDENTIALS_SECRET=rhpam-credentials \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=rhpam-kieserver-library=org.openshift.quickstarts:rhpam-kieserver-library:1.6.0-SNAPSHOT  \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=main \
-p CONTEXT_DIR=quickstarts/library-process/library \
-p AMQ_USERNAME=admin -p AMQ_PASSWORD=RedHat \
-p AMQ_SECRET=<amq_secret_with_trust_and_key_store> \
-p AMQ_TRUSTSTORE=<truststore_file_name> -p AMQ_TRUSTSTORE_PASSWORD=<truststore_password> \
-p AMQ_KEYSTORE=<keystore_file_name> -p AMQ_KEYSTORE_PASSWORD=<keystore_password> \
-p IMAGE_STREAM_NAMESPACE=openshift
```

Execute a maven install on the root directory of the library-process:
```sh
$ cd quickstarts/library-process/
# need to install as the library-client needs this dependency org.openshift.quickstarts:rhpam-kieserver-library:jar
$ mvn clean install
```

After the Kie Server and Active MQ are ready and running, execute the following command which will execute the RHPAM process
through JMS client:
```bash
$ cd library-client
$ mvn exec:java  -Dexec.args=runRemoteActiveMQExternal -Durl=myapp-amq-tcp-ssl-kieserver.apps.test.cloud \
-Dusername=<ActiveMQ_username> -Dpassword=<ActiveMQ_password> \
-Djavax.net.ssl.trustStore=<amq_client_truststore> \
-Djavax.net.ssl.trustStorePassword=<client_truststore_password>
```

Remember to update the properties above properly according your environment. Note that, the url is the exported route for the
${APPLICATION_NAME}-amq-tcp-ssl service, which should point to the port *61617*
Not that, the url should be configured without protocol and port.
If the setup is correct, a similar message will be printed:

```bash
...
runRemoteActiveMQ, using properties: url=failover://ssl://myapp-amq-tcp-ssl-kieserver.apps.test.cloud:443
runRemoteActiveMQ, using properties: username=admin
runRemoteActiveMQ, using properties: password=RedHat
Using xml MarshallingFormat.JAXB
Attempting 1st loan for isbn: 978-1-4000-5-80-2
1st loan approved? true
Attempting 2nd loan for isbn: 978-1-4000-5-80-2
2nd loan approved? true
Returning 1st loan for isbn: 978-1-4000-5-80-2
1st loan return acknowledged? true
Re-attempting 2nd loan for isbn: 978-1-4000-5-80-2
Re-attempt of 2nd loan approved? true
Received suggestion for book: Pride and Prejudice and Zombies (isbn: 978-1-59474-449-5)
Attempting 3rd loan for isbn: 978-1-59474-449-5
3rd loan approved? true
Returning 2nd loan for isbn: 978-1-4000-5-80-2
2nd loan return acknowledged? true
Returning 3rd loan for isbn: 978-1-59474-449-5
3rd loan return acknowledged? true
...
```

#### Found an issue?
Feel free to report it [here](https://github.com/jboss-container-images/rhpam-7-openshift-image/issues/new).
