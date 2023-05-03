## Red Hat Process Automation Manager KIE Server decisions Quickstart

This quickstart is intended to be used with the [RHPAM KIE Server](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/7.13.3.GA/kieserver) image.

## How to use it?

The template below will be used for this quickstart:

[rhdm713-prod-immutable-kieserver](https://github.com/jboss-container-images/rhpam-7-openshift-image/blob/7.13.3.GA/templates/decision/rhdm713-prod-immutable-kieserver.yaml) application template.

To deploy it on your OpenShift instance, just execute the following commands:


```bash
$ oc login https://<your_openshift_address>:<port>
```

Create a new project, i.e.:

```bash
$ oc new-project rhpam
Now using project "rhpam" on server "https://ocp.mycloud.com:8443".
```

Make sure you have the RHPAM template installed in your OpenShift Instance:
```bash
$ oc get template rhdm713-prod-immutable-kieserver -n openshift
Error from server (NotFound): templates "rhdm713-prod-immutable-kieserver" not found
```
If you don't have it yet, just install it:

```bash
oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.3.GA/templates/decision/rhdm713-prod-immutable-kieserver.yaml -n openshift
template "rhdm713-prod-immutable-kieserver" created
```

For this template, we also need to install the secrets, which contain the certificates to configure https:
```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.3.GA/example-app-secret-template.yaml
$ oc new-app example-app-secret -p SECRET_NAME=decisioncentral-app-secret
```


Before proceed, make sure you have the RHPAM imagestreams available under the 'openshift' namespace.

 ```bash
$ oc get imagestream rhpam-kieserver-rhel8 -n openshift | grep 7.13
Error from server (NotFound): imagestreams.image.openshift.io "rhpam-kieserver-rhel8" not found
```

If the `rhpam-kieserver-rhel8` is not found, install it under the 'openshift' namespace:
```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.3.GA/rhpam713-image-streams.yaml -n openshift
```
Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)


Deploy the `credentials secret` provided as example:

```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.3.GA/example-credentials.yaml
secret/rhpam-credentials created
```

Default credential is `adminUser/RedHat`.

At this moment we are ready to instantiate the kieserver app:

```bash
$ oc new-app rhdm713-prod-immutable-kieserver \
-p KIE_SERVER_HTTPS_SECRET=decisioncentral-app-secret \
-p CREDENTIALS_SECRET=rhpam-credentials \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=hellorules=org.openshift.quickstarts:rhpam-kieserver-decisions:1.6.0-SNAPSHOT \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=7.13.3.GA \
-p CONTEXT_DIR=quickstarts/hello-rules/hellorules \
-p IMAGE_STREAM_NAMESPACE=openshift
```

Now you can deploy the [hellorules-client](hellorules-client) in the same or another project and test RHPAM KIE Server container.

To deploy the hello rules client you can use the **eap73-basic-s2i** template and specify the above quickstart to be deployed. It should be available in the OpenShift Catalog, 
if not, follow the steps described [here](https://github.com/jboss-container-images/jboss-eap-7-openshift-image/blob/eap73/README.adoc) to install the missing template. 

You might be required to import the EAP 7.3 imagestream as well:
```bash
$ oc replace -f https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/eap73/templates/eap73-image-stream.json -n openshift
```


To do so, execute the following commands:

```bash
$ oc new-app eap73-basic-s2i \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=7.13.3.GA \
-p CONTEXT_DIR=quickstarts/hello-rules
```

After the application is built, access the hello rules client app through the route created:
```bash

$ oc get route eap-app
NAME      HOST/PORT                               PATH      SERVICES   PORT      TERMINATION   WILDCARD
eap-app   eap-app-rhdm.<your_openshift_suffix>              eap-app    <all>                   None
```

Note that this route should be resolvable.

To test the hellorules-client and the hellorules quickstart, you can use the url below that is a http request against the hellorules-client which
will call the target drools rule on the target KIE Server:

```bash
http://eap-app-rhdm-kieserver.<your_openshift_suffix>/hellorules?command=runRemoteRest&protocol=http&host=myapp-kieserver&port=8080&username=adminUser&password=RedHat
```


### JMS integration outside OpenShift - Active MQ

This example allows you to test if your JMS setup is working properly and if you are able to perform JMS calls outside OpenShift
by using the *hello-rules* quickstart and this client to interact with Active MQ.

Before proceed, clone this repository.
Follow the steps described before to:
 - install the rhdm713-prod-immutable-kieserver-amq.yaml template in the current namespace
 - install the https secret
 - credentials secret
 - Make sure that the Active MQ 7.8 imagestream is available in the `openshift` namespace. 
   ```bash
   $ oc replace -n openshift --force  -f \
     https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/78-7.8.0.GA/amq-broker-7-image-streams.yaml
   ```
 - configure the Active MQ self-signed certificates, the steps can be found [here](https://access.redhat.com/documentation/en-us/red_hat_amq/2020.q4/html/deploying_amq_broker_on_openshift/deploying_broker-on-ocp-using-templates_broker-ocp#connecting-external-clients-to-template-based-brokers_broker-ocp)

 
After properly configuring the Active-MQ pre requisites, deploy the KIE Server using the AMQ Application template:
To deploy the template execute the following command:

```bash
$ oc new-app rhdm713-prod-immutable-kieserver-amq \
-p KIE_SERVER_HTTPS_SECRET=decisioncentral-app-secret \
-p CREDENTIALS_SECRET=rhpam-credentials \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=hellorules=org.openshift.quickstarts:rhpam-kieserver-decisions:1.6.0-SNAPSHOT \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=7.13.3.GA \
-p CONTEXT_DIR=quickstarts/hello-rules/hellorules \
-p AMQ_USERNAME=admin -p AMQ_PASSWORD=RedHat \
-p AMQ_SECRET=<amq_secret_with_trust_and_key_store> \
-p AMQ_TRUSTSTORE=<truststore_file_name> -p AMQ_TRUSTSTORE_PASSWORD=<truststore_password> \
-p AMQ_KEYSTORE=<keystore_file_name> -p AMQ_KEYSTORE_PASSWORD=<keystore_password> \
-p IMAGE_STREAM_NAMESPACE=openshift
```


Execute a maven install on the root directory of the hello-rules:
```sh
$ cd quickstarts/hello-rules
# need to install as the hellorules-client needs this dependency org.openshift.quickstarts:rhpam-kieserver-decisions:jar
$ mvn clean install
```

After the KIE Server and Active MQ are ready and running, execute the following command which will execute the RHPAM decision
through JMS client:

```bash
$ cd hellorules-client
$ mvn exec:java  -Dexec.args=runRemoteActiveMQExternal -Dhost=myapp-amq-tcp-ssl-kieserver.apps.test.cloud \
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
[HelloRulesClient.main()] INFO HelloRulesClient - ---------> baseurl: failover://ssl://myapp-amq-tcp-ssl-kieserver.apps.test.cloud:443
runRemoteActiveMQ, using properties: url=failover://ssl://myapp-amq-tcp-ssl-kieserver.apps.test.cloud:443
runRemoteActiveMQ, using properties: username=<ActiveMQ_username>
runRemoteActiveMQ, using properties: password=<ActiveMQ_password>
...
[ActiveMQ Task-1] INFO org.apache.activemq.transport.failover.FailoverTransport - Successfully connected to ssl://myapp-amq-tcp-ssl-kieserver.apps.test.cloud:443
[HelloRulesClient.main()] INFO HelloRulesClient - ********** Hello spolti! **********
```


#### Found an issue?
Feel free to report it [here](https://github.com/jboss-container-images/rhpam-7-openshift-image/issues/new).
