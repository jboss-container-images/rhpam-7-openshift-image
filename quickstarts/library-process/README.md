## Red Hat Process Automation Manager Kie Server Quickstart

Note that, this is the development branch, the target images might not be available here, instead you can look at the [released branch](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/7.9.x/quickstarts/library-process)

This quickstart is intend to be used with the [RHPAM Kie Server](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/master/kieserver) image.

## How to use it?

To deploy the Library Process demo you can use the [rhpam79-prod-immutable-kieserver](https://github.com/jboss-container-images/rhpam-7-openshift-image/blob/master/templates/rhpam79-prod-immutable-kieserver.yaml)

To deploy it on your OpenShift instance, just execute the following commands:

```bash
$ oc login https://<your_openshift_address>:<port>
Authentication required for https://ocp-master.cloud.com:8443 (openshift)
Username: developer
Password:
Login successful.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    kube-public
    kube-system
    logging
    management-infra
    nexus
    openshift
    openshift-infra
    openshift-node

Using project "default".
```
```bash
$ oc new-project rhpam-kieserver
Now using project "rhpam-kieserver" on server "https://ocp-master.cloud.com:8443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app centos/ruby-22-centos7~https://github.com/openshift/ruby-ex.git

to build a new example application in Ruby.
```

Make sure that you have the RHPAM template installed in your OpenShift Instance:
```bash
$ oc get template rhpam79-prod-immutable-kieserver -n openshift
Error from server (NotFound): templates.template.openshift.io "rhpam79-prod-immutable-kieserver" not found
```

If you don't have it yet, just install it:

```bash
oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/templates/rhpam79-prod-immutable-kieserver.yaml -n openshift
template.template.openshift.io "rhpam79-prod-immutable-kieserver" created
```

For this template, we also need to install the secrets, which contain the certificates to configure https:
```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/example-app-secret-template.yaml
template.template.openshift.io "example-app-secret" created
$ oc new-app example-app-secret -p SECRET_NAME=businesscentral-app-secret
--> Deploying template "rhpam-kieserver/example-app-secret" to project rhpam-kieserver

     example-app-secret
     ---------
     Examples that can be installed into your project to allow you to test the Red Hat Business Central templates. You should replace the contents with data that is more appropriate for your deployment.

     * With parameters:
        * Secret Name=businesscentral-app-secret

--> Creating resources ...
    secret "businesscentral-app-secret" created
--> Success
    Run 'oc status' to view your app
```

Before proceed, make sure you have the RHDM imagestreams available under the 'openshift' namespace.

```bash
$ oc get imagestream rhpam-kieserver-rhel8 -n openshift | grep 7.9
Error from server (NotFound): imagestreams.image.openshift.io "rhpam-kieserver-rhel8" not found

```
 If the `rhpam-kieserver-rhel8` is not found, install it under the 'openshift' namespace:
 ```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/master/rhpam79-image-streams.yaml -n openshift
```

Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)

At this moment we are ready to instantiate the kieserver app:

```bash
$ oc new-app rhpam79-prod-immutable-kieserver \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=rhpam-kieserver-library=org.openshift.quickstarts:rhpam-kieserver-library:1.6.0-SNAPSHOT \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=master \
-p CONTEXT_DIR=quickstarts/library-process/library \
-p KIE_SERVER_HTTPS_SECRET=businesscentral-app-secret \
-p IMAGE_STREAM_NAMESPACE=openshift
--> Deploying template "openshift/rhpam79-prod-immutable-kieserver" to project rhpam-kieserver

     Red Hat Process Automation Manager 7.9 immutable production environment
     ---------
     Application template for an immultable KIE server in a production environment, for Red Hat Process Automation Manager 7.9

     A new immutable Red Hat Process Automation Manager KIE server have been created in your project.
     The username/password for accessing the KIE server is

         Username: executionUser
         Password: MADQFF7!

     Please be sure to create the secret named "businesscentral-app-secret" containing the keystore.jks files used for serving secure content.

     * With parameters:
        * Application Name=myapp
        * KIE Admin User=adminUser
        * KIE Admin Password=qKimRR7! # generated
        * KIE Server User=executionUser
        * KIE Server Password=MADQFF7! # generated
        * ImageStream Namespace=openshift
        * KIE Server ImageStream Name=rhpam-kieserver-rhel8
        * ImageStream Tag=7.9.0
        * KIE Server Monitor User=monitorUser
        * KIE Server Monitor Password=
        * KIE Server Monitor Token=
        * KIE Server Monitor Service=
        * Smart Router Service=
        * Smart Router Host=
        * Smart Router listening port=
        * Smart Router protocol=
        * KIE Server Persistence DS=java:/jboss/datasources/rhpam
        * PostgreSQL ImageStream Namespace=openshift
        * PostgreSQL ImageStream Tag=9.6
        * KIE Server PostgreSQL Database User=rhpam
        * KIE Server PostgreSQL Database Password=nFVlBu6! # generated
        * KIE Server PostgreSQL Database Name=rhpam7
        * PostgreSQL Database max prepared connections=100
        * Database Volume Capacity=1Gi
        * Drools Server Filter Classes=true
        * KIE MBeans=enabled
        * KIE Server Custom http Route Hostname=
        * KIE Server Custom https Route Hostname=
        * Use the secure route name to set KIE_SERVER_HOST.=false
        * KIE Server Keystore Secret Name=businesscentral-app-secret
        * KIE Server Keystore Filename=keystore.jks
        * KIE Server Certificate Name=jboss
        * KIE Server Keystore Password=mykeystorepass
        * KIE Server Bypass Auth User=false
        * KIE Server Container Deployment=rhpam-kieserver-library=org.openshift.quickstarts:rhpam-kieserver-library:1.6.0-SNAPSHOT
        * Git Repository URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git
        * Git Reference=master
        * Context Directory=quickstarts/library-process/library
        * Github Webhook Secret=gS02j8C0 # generated
        * Generic Webhook Secret=NxH5PHEs # generated
        * Maven mirror URL=
        * Maven repository ID=
        * Maven repository URL=
        * Maven repository username=
        * Maven repository password=
        * Name of the Maven service hosted by Business Central=
        * Username for the Maven service hosted by Business Central=
        * Password for the Maven service hosted by Business Central=
        * List of directories from which archives will be copied into the deployment folder=
        * Timer service data store refresh interval (in milliseconds)=30000
        * KIE Server Container Memory Limit=1Gi
        * Disable KIE Server Management=true
        * KIE Server Startup Strategy=LocalContainersStartupStrategy
        * RH-SSO URL=
        * RH-SSO Realm name=
        * KIE Server RH-SSO Client name=
        * KIE Server RH-SSO Client Secret=
        * RH-SSO Realm Admin Username=
        * RH-SSO Realm Admin Password=
        * RH-SSO Disable SSL Certificate Validation=false
        * RH-SSO Principal Attribute=preferred_username
        * LDAP Endpoint=
        * LDAP Bind DN=
        * LDAP Bind Credentials=
        * LDAP JAAS Security Domain=
        * LDAP Base DN=
        * LDAP Base Search filter=
        * LDAP Search scope=
        * LDAP Search time limit=
        * LDAP DN attribute=
        * LDAP Parse username=
        * LDAP Username begin string=
        * LDAP Username end string=
        * LDAP Role attributeID=
        * LDAP Roles Search DN=
        * LDAP Role search filter=
        * LDAP Role recursion=
        * LDAP Default role=
        * LDAP Role name attribute ID=
        * LDAP Role DN contains roleNameAttributeID=
        * LDAP Role Attribute ID is DN=
        * LDAP Referral user attribute ID=

--> Creating resources ...
    serviceaccount "myapp-kieserver" created
    rolebinding "myapp-kieserver-view" created
    service "myapp-kieserver" created
    service "myapp-kieserver-ping" created
    service "myapp-postgresql" created
    route "myapp-kieserver" created
    route "secure-myapp-kieserver" created
    imagestream "myapp-kieserver" created
    buildconfig "myapp-kieserver" created
    deploymentconfig "myapp-kieserver" created
    deploymentconfig "myapp-postgresql" created
    persistentvolumeclaim "myapp-postgresql-claim" created
--> Success
    Access your application via route 'myapp-kieserver-rhpam-kieserver.mycloud.com'
    Access your application via route 'secure-myapp-kieserver-rhpam-kieserver.mycloud.com'
    Build scheduled, use 'oc logs -f bc/myapp-kieserver' to track its progress.
    Run 'oc status' to view your app.
```

Now you can deploy the [library-client](library-client) in the same or another project and test RHPAM Kie Server container.

To deploy the library process client you can use the **eap72-basic-s2i** (It is available in the OpenShift Catalog) template and specify the above quickstart to be deployed.
To do so, execute the following commands:

```bash
$ oc new-app eap72-basic-s2i \
    -p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
    -p SOURCE_REPOSITORY_REF=master \
    -p CONTEXT_DIR=quickstarts/library-process
```

As result you should see something like this:
```bash
--> Deploying template "openshift/eap72-basic-s2i" to project rhpam-kieserver

     JBoss EAP 7.1 (no https)
     ---------
     An example EAP 7 application. For more information about using this template, see https://github.com/jboss-openshift/application-templates.

     A new EAP 7 based application has been created in your project.

     * With parameters:
        * Application Name=eap-app
        * Custom http Route Hostname=
        * Git Repository URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git
        * Git Reference=master
        * Context Directory=quickstarts/library-process
        * Queues=
        * Topics=
        * A-MQ cluster password=6KfAF1lb # generated
        * Github Webhook Secret=Pgd31VYF # generated
        * Generic Webhook Secret=iDauFU6A # generated
        * ImageStream Namespace=openshift
        * JGroups Cluster Password=KuM0xJFR # generated
        * Deploy Exploded Archives=false
        * Maven mirror URL=
        * Maven Additional Arguments=-Dcom.redhat.xpaas.repo.jbossorg
        * ARTIFACT_DIR=
        * MEMORY_LIMIT=1Gi

--> Creating resources ...
    service "eap-app" created
    service "eap-app-ping" created
    route "eap-app" created
    imagestream "eap-app" created
    buildconfig "eap-app" created
    deploymentconfig "eap-app" created
--> Success
    Access your application via route 'eap-app-rhpam-kieserver.mycloud.com'
    Build scheduled, use 'oc logs -f bc/eap-app' to track its progress.
    Run 'oc status' to view your app.
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
http://eap-app-rhpam-kieserver.<your_openshift_suffix>/library?command=runRemoteRest&protocol=http&host=myapp-kieserver&port=8080&username=executionUser&password=<the_generated_kie_password>
```

The password was generated during the app creation in the previous steps, look for **KIE Server Password**.


### JMS integration outside OpenShift

Remember, the certificates are required, for more information about how to configure the AMQ properties, please see:
https://access.redhat.com/documentation/en-us/red_hat_amq/7.3/html/deploying_amq_broker_on_openshift_container_platform/configure-ssl-broker-ocp#configuring-ssl_broker-ocp

This client allows you to test if your JMS setup is working properly and if you are able to perform JMS calls outside OpenShift
by using the *library-process* quickstart and this client to interact with ActiveMQ.

First of all, install this quickstart on OpenShift using the [rhpam79-prod-immutable-kieserver-amq.yaml](../../templates/rhpam79-prod-immutable-kieserver-amq.yaml)
and do not forget to properly configure the S2i build and the AMQ parameters, mainly the credentials.


Execute a maven install on the root directory of the library-process:
```sh
$pwd .../rhpam-7-openshift-image/quickstarts/library-process
$ mvn clean install
```

After the quickstart is properly deployed on OpenShift, execute the following commands
```bash
$ mvn exec:java  -Dexec.args=runRemoteActiveMQExternal -Durl=myapp-amq-tcp-ssl-kieserver.apps.test.cloud \
-Dusername=admin -Dpassword=redhat@123 \
-Djavax.net.ssl.trustStore=/tmp/broker/client.ts \
-Djavax.net.ssl.trustStorePassword=123456
```

Remember to update the properties above properly according your environment. Note that, the url is the exported route for the
${APPLICATION_NAME}-amq-tcp-ssl service, which should point to the port *61617*
Not that, the url should be configured without protocol and port.

If the setup is correct, a similar message will be printed:
```bash
...
runRemoteActiveMQ, using properties: url=failover://ssl://myapp-amq-tcp-ssl-kieserver.apps.test.cloud:443
runRemoteActiveMQ, using properties: username=admin
runRemoteActiveMQ, using properties: password=redhat@123
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
