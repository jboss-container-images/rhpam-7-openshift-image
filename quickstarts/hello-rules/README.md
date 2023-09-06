## IBM Business Automation Manager Open Editions KIE Server decisions Quickstart

This quickstart is intended to be used with the [IBM BAMOE KIE Server](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/8.0.3.GA/kieserver) image.

## How to use it?

In order to be able to execute this quickstart, you need a working IBM BAMOE environment.

Before proceeding with the IBM BAMOE environment setup, it is better to create a new project on OpenShift where we will create all the resources needed.

To deploy it on your OpenShift instance, just execute the following commands:


```bash
$ oc login https://<your_openshift_address>:<port>
```

Create a new project, i.e.:

```bash
$ oc new-project ibm-bamoe
Now using project "ibm-bamoe" on server "https://ocp-main.mycloud.com:8443".
```

Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)

To create the IBM BAMOE environment  on your OpenShift instance you need to install Business Automation Operator.
For instructions about installing Business Automation Operator, see [the product documentation](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.13/html/deploying_red_hat_process_automation_manager_on_red_hat_openshift_container_platform/operator-con_openshift-operator#operator-subscribe-proc_openshift-operator) step.

Then access the wizard installer, instructions available [here](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.13/html/deploying_red_hat_process_automation_manager_on_red_hat_openshift_container_platform/operator-con_openshift-operator#operator-environment-deploy-assy_openshift-operator)

If you view the generated YAML source for the installation, the source should be similar to the following example:

```yaml
apiVersion: app.kiegroup.org/v2
kind: KieApp
metadata:
   name: hello-rules-quickstart
spec:
   environment: rhpam-production-immutable
...
```   

When your KieApp will be ready and running, you can go ahead deploying the [hellorules-client](hellorules-client) in the same or another project and test IBM BAMOE KIE Server container.

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
-p SOURCE_REPOSITORY_REF=main \
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
will call the target drools rule on the target kieserver:

```bash
http://eap-app-rhdm-kieserver.<your_openshift_suffix>/hellorules?command=runRemoteRest&protocol=http&host=myapp-kieserver&port=8080&username=adminUser&password=RedHat
```


### JMS integration outside OpenShift - Active MQ

This example allows you to test if your JMS setup is working properly and if you are able to perform JMS calls outside OpenShift
by using the *hello-rules* quickstart and this client to interact with Active MQ.

Before proceed, clone this repository.
Follow the steps described before to:
- install the KieApp using the *Enable JMS Integration* setting as described in the  Business Automation Operator documentation [here](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.13/html/deploying_red_hat_process_automation_manager_on_red_hat_openshift_container_platform/operator-con_openshift-operator#operator-deploy-kieserver-proc_openshift-operator) at step 13.

After properly configuring the Active-MQ pre requisites, you have to wait the KieApp gets ready before continuing.

Execute a maven install on the root directory of the hello-rules:
```sh
$ cd quickstarts/hello-rules
# need to install as the hellorules-client needs this dependency org.openshift.quickstarts:rhpam-kieserver-decisions:jar
$ mvn clean install
```

After the KIE Server and Active MQ are ready and running, execute the following command which will execute the IBM BAMOE decision
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