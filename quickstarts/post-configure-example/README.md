# JBoss CLI PostConfigure example

This example will explain how to create additional JBoss EAP users using the Post Configure feature available on the
Container images based on JBoss EAP.

The steps described on this quickstart will work on the following container images:

- RHPAM KIE Server
- RHDM KIE Server
- Business Central
- Business Central Monitoring
- Decision Central
- Dashbuilder
- RHPAM/DM Controller

Note: This procedure can be applied to any kind of post configure actions.

## Preparing the needed files

Before deployment, prepare the required files. You must have the following files:

- [add-users.cli](add-users.cli): JBoss CLI Batch script, your script must be added between the commands below:
  ```bash
  embed-server --std-out=echo --server-config=standalone-openshift.xml batch

  <your jboss-cli commands>

  run-batch 
  quit
  ```

- [delayedpostconfigure.sh](delayedpostconfigure.sh): This empty file is needed until the following jira is fixed:
  https://issues.redhat.com/browse/RHPAM-3665

- [postconfigure.sh](postconfigure.sh): The script that will actually call the JBoss-CLI script.

With these 3 files in place, the next step is to create a config-map and mount it under `/opt/eap/extensions` directory on
the target container image(s).

#### Creating the config map

```bash
$ oc create configmap postconfigure \
    --from-file=add-users.cli=add-users.cli \
    --from-file=delayedpostconfigure.sh=delayedpostconfigure.sh \
    --from-file=postconfigure.sh=postconfigure.sh
configmap/postconfigure created
```

If you inspect the created config-map, the result would be something like:

```bash
$ oc describe cm postconfigure
Name:         postconfigure
Namespace:    add-users-example
Labels:       <none>
Annotations:  <none>

Data
====
add-users.cli:
----
embed-server --std-out=echo  --server-config=standalone-openshift.xml
batch

/subsystem=elytron/filesystem-realm=KieFsRealm:add-identity(identity=user1)
/subsystem=elytron/filesystem-realm=KieFsRealm:set-password(identity=user1, clear={password="pass123*"})
/subsystem=elytron/filesystem-realm=KieFsRealm:add-identity-attribute(identity=user1, name=role, value=["kie-server","rest-all","admin","kiemgmt","Administrators","user"])

/subsystem=elytron/filesystem-realm=KieFsRealm:add-identity(identity=user2)
/subsystem=elytron/filesystem-realm=KieFsRealm:set-password(identity=user2, clear={password="pass123*"})
/subsystem=elytron/filesystem-realm=KieFsRealm:add-identity-attribute(identity=user2, name=role, value=["kie-server","rest-all","admin","kiemgmt"])

run-batch
quit

delayedpostconfigure.sh:
----
This empty file is needed until the following jira is fixed:
https://issues.redhat.com/browse/RHPAM-3665

postconfigure.sh:
----
echo "******  RUNNING ADDITIONAL CONFIGURATIONS WITH JBOSS-CLI - ADDING EXTRA ELYTRON USERS TO KIE FS REALM **********"
echo "trying to execute /opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli"
/opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli
echo "END - users added"

Events:  <none>
```

With the config-map created, you can now proceed with the container configuration. In this example there is only one KIE
Server running. the steps are different depending on whether you use the `operator` or `application` templates to deploy
the product.

### Application Templates method:

When using the `application templates` or an already running RHPAM instance, with the config map created, mount it as
a `volume` on the desired Deployment Config:

```bash
$ oc set volumes dc/myapp-kieserver --add  \
    --configmap-name=postconfigure \
    --mount-path=/opt/eap/extensions \
    --default-mode=0555
```

Note: If the target *dc* is other than `myapp-kieserver` remember to update it to fit your needs. This change will make
the running KIE Server be redeployed, after it starts again you should see a message similar to:

```bash
******  RUNNING ADDITIONAL CONFIGURATIONS WITH JBOSS-CLI - ADDING EXTRA ELYTRON USERS TO KIE FS REALM **********
trying to execute /opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli
...
some jboss logging output
...
The batch executed successfully
15:33:07,651 INFO  [org.jboss.as] (MSC service thread 1-2) WFLYSRV0050: JBoss EAP 7.4.1.GA (WildFly Core 15.0.4.Final-redhat-00001) stopped in 40ms
END - users added
```

### Operator method

To install the operator please follow the steps described in
this [link](https://access.redhat.com/documentation/en-us/red_hat_process_automation_manager/7.12/html/deploying_red_hat_process_automation_manager_on_red_hat_openshift_container_platform/operator-con_openshift-operator)
. After the operator installed and ready to use, you need to edit the `kieconfig-<current-version>`, in this
case, `7.12.0`. With the operator already running in the current namespace, follow the steps below:

- Create the [config-map](#creating-the-config-map) in the current namespace as described above.
- Edit the `kieconfigs-7.12.0` config map, you can use either the OCP Web UI or the command line tool, in this example
  we'll use the command line tool:

  ```bash
  $ oc edit cm kieconfigs-7.12.0
  ```

In this case, as we are going to update the KIE Server deployment, you need to update the `servers` section of the
common.yaml content. If it was for `Business Central, Monitoring or Decision Central`, then the `console` section needs
to be updated. If it is the `Dashbuilder` then the configMap called `kieconfigs-7.12.0-dashbuilder` needs to be edited.

First, let's locate where is the `servers` section.

Under `deploymentConfigs.metadata.spec.template.spec.containers.volumeMounts`, add the following:

```yaml
- name: postconfigure-mount
  mountPath: /opt/eap/extensions
```

And under `deploymentConfigs.metadata.spec.template.spec.volumes`, add the following:

```yaml
- name: "postconfigure-mount"
  configMap:
    name: "postconfigure"
    defaultMode: 0555
```

Now, save it and create a simple KieApp, like the example below:

```yaml
apiVersion: app.kiegroup.org/v2
kind: KieApp
metadata:
  name: rhpam-trial
  annotations:
    consoleName: rhpam-trial
    consoleTitle: PAM Trial
    consoleDesc: Deploys a PAM Trial environment
spec:
  environment: rhpam-trial
```

Depending on the environment it could take a while until the volume is mounted and the pod started. After the KIE Server
is started, you should see the same output from `application template` method:

```bash
******  RUNNING ADDITIONAL CONFIGURATIONS WITH JBOSS-CLI - ADDING EXTRA ELYTRON USERS TO KIE FS REALM **********
trying to execute /opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/add-users.cli
...
some jboss logging output
...
The batch executed successfully
15:33:07,651 INFO  [org.jboss.as] (MSC service thread 1-2) WFLYSRV0050: JBoss EAP 7.4.1.GA (WildFly Core 15.0.4.Final-redhat-00001) stopped in 40ms
END - users added
```

Note: If the KieApp is already running and the updated pods does not restart automatically, you can just delete the
deployment config so the `operator` can start an updated version.

#### Found an issue?

Please submit an issue [here](https://issues.jboss.org/projects/RHPAM) with the **Cloud** tag or send us a email:
bsig-cloud@redhat.com.

