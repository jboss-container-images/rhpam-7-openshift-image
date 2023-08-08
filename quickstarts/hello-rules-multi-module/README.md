## Red Hat Process Automation Manager KIE Server decisions Quickstart - Multi module

This quickstart is intended to be used with the [RHPAM Kie Server](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/7.13.3-1.GA/kieserver) image.

## How to use it?

To deploy the Hello Rules demo you can use the [rhdm713-prod-immutable-kieserver](https://github.com/jboss-container-images/rhpam-7-openshift-image/blob/7.13.3-1.GA/templates/decision/rhdm713-prod-immutable-kieserver.yaml) application template.


To deploy it on your OpenShift instance, just execute the following commands:

```bash
$ oc login https://<your_openshift_address>:<port>
```

Create a new project, i.e.:

```bash
$ oc new-project rhpam
Now using project "rhpam" on server "https://ocp-main.mycloud.com:8443".
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

Deploy the `credentials secret` provided as example:

```bash
$ oc create -f https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.13.3.GA/example-credentials.yaml
secret/rhpam-credentials created
```

Default credential is `adminUser/RedHat`.

Note that, to pull the images the OpenShift must be able to pull images from registry.redhat.io, for more information
please take a look [here](https://access.redhat.com/RegistryAuthentication)

At this moment we are ready to instantiate the kieserver app:


```bash
$ oc new-app rhdm713-prod-immutable-kieserver \
-p KIE_SERVER_HTTPS_SECRET=decisioncentral-app-secret \
-p CREDENTIALS_SECRET=rhpam-credentials \
-p KIE_SERVER_CONTAINER_DEPLOYMENT=hellorules=org.openshift.quickstarts:rhpam-kieserver-decisions:1.6.0-SNAPSHOT \
-p ARTIFACT_DIR=hellorules/target,hellorules-model/target \
-p SOURCE_REPOSITORY_URL=https://github.com/jboss-container-images/rhpam-7-openshift-image.git \
-p SOURCE_REPOSITORY_REF=7.13.3.GA \
-p CONTEXT_DIR=quickstarts/hello-rules-multi-module \
-p IMAGE_STREAM_NAMESPACE=openshift
```


Now you can deploy the [hellorules-client](hellorules-client) in the same or another project and test RHPAM KIE Server container.

To deploy the hello rules client you can use the **eap73-basic-s2i** template and specify the above quickstart to be deployed. It should available in the OpenShift Catalog, 
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

#### Found an issue?
Feel free to report it [here](https://github.com/jboss-container-images/rhpam-7-openshift-image/issues/new).
