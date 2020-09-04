## Red Hat Process Automation Manager SmartRouter Extension Example

Note: this is the development branch, the target images might not be available here, instead you can look at the [release branch](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/7.9.x/quickstarts/router-ext)

Use this quick start guide with the [RHPAM SmartRouter](https://github.com/jboss-container-images/rhpam-7-openshift-image/tree/master/smartrouter) image.

The SmartRouter extension is used to extend the Smart Router functionality to make it to adapt the routing to your needs.
This example provides a very simple custom Kie Container resolver based on the Kie Container version and how you can add this
extension to a custom Smart Router image.

## Using the example SmartRouter extension

Build the source code with Maven:

```bash
$ mvn clean package
```

The build process will generate the following jar: `target/router-ext-0.0.1-SNAPSHOT.jar` 

After building the Smart Router extension, you can prepare the environment to extend the `registry.redhat.io/rhpam-7/rhpam-smartrouter-rhel8:7.9.0` image 
and customize it, to include the recently built Smart Router extension.

If you don't have the Smart Router image on your local registry, pull it:

```bash
$ docker pull registry.redhat.io/rhpam-7/rhpam-smartrouter-rhel8:7.9.0
```

Create a directory for building the custom Smart Router Image. For this example I'll be using the tmp directory.

```bash
$ mkdir /tmp/smartrouter
$ cp target/router-ext-0.0.1-SNAPSHOT.jar /tmp/smartrouter
$ cd /tmp/smartrouter
```

To extract the `openshift-launch.sh` file from the official Smart Router image, enter the following command:

```bash
$ docker run --rm registry.redhat.io/rhpam-7/rhpam-smartrouter-rhel8:7.9.0 \
    cat /opt/rhpam-smartrouter/openshift-launch.sh > openshift-launch.sh
```

Check the file content, it should be the same as [this file](https://github.com/jboss-container-images/jboss-kie-modules/blob/rhpam-7.9.0.GA/jboss-kie-smartrouter/added/openshift-launch.sh).
Edit the file. In the last line of the file, change the `exec` instruction from:

```bash
exec ${JAVA_HOME}/bin/java ${SHOW_JVM_SETTINGS} ${JAVA_OPTS} ${JAVA_OPTS_APPEND} ${JAVA_PROXY_OPTIONS} "${D_ARR[@]}" -jar /opt/${JBOSS_PRODUCT}/${KIE_ROUTER_DISTRIBUTION_JAR}
```

To:

```bash
exec ${JAVA_HOME}/bin/java ${SHOW_JVM_SETTINGS} "${D_ARR[@]}" \
    -cp /opt/${JBOSS_PRODUCT}/router-ext-0.0.1-SNAPSHOT.jar:/opt/${JBOSS_PRODUCT}/${KIE_ROUTER_DISTRIBUTION_JAR} \
    org.kie.server.router.KieServerRouter
```

This change adds the extension JAR file to the Java Class Path.
Next, build the custom Smart Router image.

Create a file called Dockerfile with the following content:

```bash
from registry.redhat.io/rhpam-7/rhpam-smartrouter-rhel8:7.9.0

RUN rm -rfv /opt/rhpam-smartrouter/openshift-launch.sh
COPY openshift-launch.sh  /opt/rhpam-smartrouter/openshift-launch.sh

COPY router-ext-0.0.1-SNAPSHOT.jar /opt/rhpam-smartrouter/router-ext-0.0.1-SNAPSHOT.jar

USER root
RUN chown jboss. /opt/rhpam-smartrouter/router-ext-0.0.1-SNAPSHOT.jar /opt/rhpam-smartrouter/openshift-launch.sh
RUN chmod +x /opt/rhpam-smartrouter/openshift-launch.sh

# run image with jboss user.
USER 185
```

Now, build the image:

```bash
$ docker build -t my-smartrouter-ext:1.0 .
docker build -t my-smartrouter-ext:1.0 .
Sending build context to Docker daemon   12.8kB
Step 1/8 : from registry.redhat.io/rhpam-7/rhpam-smartrouter-rhel8:7.9.0
 ---> 1822bf9d5565
Step 2/8 : RUN rm -rfv /opt/rhpam-smartrouter/openshift-launch.sh
 ---> Using cache
 ---> f9bcb5f6581f
Step 3/8 : COPY openshift-launch.sh  /opt/rhpam-smartrouter/openshift-launch.sh
 ---> Using cache
 ---> bb9cd6c473db
Step 4/8 : COPY router-ext-0.0.1-SNAPSHOT.jar /opt/rhpam-smartrouter/router-ext-0.0.1-SNAPSHOT.jar
 ---> 490e27e594a0
Step 5/8 : USER root
 ---> Running in 70ad33a793ee
Removing intermediate container 70ad33a793ee
 ---> eb73b95c8e51
Step 6/8 : RUN chown jboss. /opt/rhpam-smartrouter/router-ext-0.0.1-SNAPSHOT.jar /opt/rhpam-smartrouter/openshift-launch.sh
 ---> Running in 78597febac3b
Removing intermediate container 78597febac3b
 ---> 3b1678c0def8
Step 7/8 : RUN chmod +x /opt/rhpam-smartrouter/openshift-launch.sh
 ---> Running in a13e36a57a50
Removing intermediate container a13e36a57a50
 ---> e5829697cb44
Step 8/8 : USER 185
 ---> Running in 5639fe7e585f
Removing intermediate container 5639fe7e585f
 ---> 18a546161039
Successfully built 18a546161039
Successfully tagged my-smartrouter-ext:1.0
```

To verify the built image, check that the `openshift-launch.sh` script was correctly updated:

```bash
$ docker run --rm my-smartrouter-ext:1.0 cat /opt/rhpam-smartrouter/openshift-launch.sh
...
exec ${JAVA_HOME}/bin/java ${SHOW_JVM_SETTINGS} "${D_ARR[@]}" \
    -cp /opt/${JBOSS_PRODUCT}/router-ext-0.0.1-SNAPSHOT.jar:/opt/${JBOSS_PRODUCT}/${KIE_ROUTER_DISTRIBUTION_JAR} \
    org.kie.server.router.KieServerRouter
```

If the output is the same, you are ready to proceed and run the image to make sure it is working:

```bash
...
INFO: Using 'LatestVersionContainerResolver' container resolver and restriction policy 'ByPassUserNotAllowedRestrictionPolicy'
...
INFO: KieServerRouter started on :9000 at Tue Sep 01 20:23:08 UTC 2020
```

`LatestVersionContainerResolver` is the custom container resolver that the extension adds to the 
Smart Router image.


## Deploying the custom image on OpenShift using RHPAM Operator.

For this tutorial, I'll be using the CodeReady Containers.
For instructions about installing CodeReady Containers, see [Install OpenShift on a laptop with CodeReady Containers](https://cloud.redhat.com/openshift/install/crc/installer-provisioned?intcmp=7013a000002CtetAAC)

Start CRC and log in, when CRC starts the credentials are printed in the logs, for example:

```bash
$ crc start
...
INFO Then you can access it by running 'oc login -u developer -p developer https://api.crc.testing:6443' 
INFO To login as an admin, run 'oc login -u kubeadmin -p ILWgF-VfgcQ-p6mJ4-Jztez https://api.crc.testing:6443'
```

Log in using the `oc` command utility (just copy the oc login command, similar to the example above):

```bash
$ oc login -u kubeadmin -p ILWgF-VfgcQ-p6mJ4-Jztez https://api.crc.testing:6443
...
Using project "default".
```

Create a new namespace and log in to the CRC registry:
```bash
$ oc new-project rhpam-smartrouter
$ docker login -p $(oc whoami -t) -u unused default-route-openshift-image-registry.apps-crc.testing
```

Before proceeding further, tag the custom Smart Router Image that was built in the previous steps and push it to the CRC registry
to enable its use in your namespace:

```bash
$ docker tag my-smartrouter-ext:1.0 default-route-openshift-image-registry.apps-crc.testing/rhpam-smartrouter/my-smartrouter-ext:1.0
$ docker push default-route-openshift-image-registry.apps-crc.testing/rhpam-smartrouter/my-smartrouter-ext:1.0
The push refers to repository [default-route-openshift-image-registry.apps-crc.testing/rhpam-smartrouter/my-smartrouter-ext]
...
1.0: digest: sha256:f3ab6429871c88815a8ebd3b0f4d38794a342980bb518f87a3d4512cd041f576 size: 1989
```
In this example, `rhpam-smartrouter` is the namespace that you created.

Check that the image is present:

```bash
$ oc get imagestream
NAME                 IMAGE REPOSITORY                                                                               TAGS      UPDATED
my-smartrouter-ext   default-route-openshift-image-registry.apps-crc.testing/rhpam-smartrouter/my-smartrouter-ext   1.0       2 minutes ago
```

Now proceed to the OpenShift Web Console, use the following `crc` command to open it:
```bash
# opens the console in the web browser
$ crc console
# gets the crc credentials
$ crc console --credentials
```

After logging in, select the project that you created (rhpam-smartrouter) and install Business Automation Operator in this namespace.
For instructions about installing Business Automation Operator, see [the product documentation](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.8/html/deploying_a_red_hat_process_automation_manager_environment_on_red_hat_openshift_container_platform_using_operators/operator-con#operator-subscribe-proc) step.

Then access the wizard installer, instructions available [here](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.8/html/deploying_a_red_hat_process_automation_manager_environment_on_red_hat_openshift_container_platform_using_operators/operator-con#operator-deploy-start-proc)

To configure the Environment with Smart Router follow the steps described in this [section](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.8/html/deploying_a_red_hat_process_automation_manager_environment_on_red_hat_openshift_container_platform_using_operators/operator-con#operator-deploy-smartrouter-proc).
To use a custom Smart Router image, fill the following fields in the wizard installer:

```bash
Image Context -> rhpam-smartrouter (the namespace we've pushed the image previously)
Image -> my-smartrouter-ext (the image name)
Image tag -> 1.0
```

If you view the generated YAML source for the installation, the source should be similar to the following example:
```yaml
apiVersion: app.kiegroup.org/v2
kind: KieApp
metadata:
  name: smartrouter-ext-example
spec:
  environment: rhpam-trial
  objects:
    console:
      replicas: 1
    servers:
      - id: kieserver
        name: kieserver
        replicas: 1
    smartRouter:
      imageContext: rhpam-smartrouter
      image: my-smartrouter-ext
      imageTag: '1.0'
      replicas: 1
```

Proceed by clicking on the `Deploy` button. When the deployment completes, make sure all the pods are running:
```bash
$ oc get pods
NAME                                           READY     STATUS      RESTARTS   AGE
kieserver-2-deploy                             0/1       Completed   0          20m
kieserver-2-f7j7q                              1/1       Running     0          20m
smartrouter-ext-example-rhpamcentr-2-deploy    0/1       Completed   0          20m
smartrouter-ext-example-rhpamcentr-2-vmtkc     1/1       Running     0          20m
smartrouter-ext-example-smartrouter-1-deploy   0/1       Completed   0          29m
smartrouter-ext-example-smartrouter-1-krklj    1/1       Running     0          29m
```

At this point the environment is ready to use.
To make sure the custom Smart Router extension is really in use, check the logs of the Smart Router pod and look for the
custom class added in the extension:

```bash
$ oc logs smartrouter-ext-example-smartrouter-1-krklj
...
INFO: Using 'LatestVersionContainerResolver' container resolver and restriction policy 'ByPassUserNotAllowedRestrictionPolicy'
```


#### Found an issue?
Feel free to report it [here](https://github.com/jboss-container-images/rhpam-7-openshift-image/issues/new).
