# Build JDBC Driver images

This repository provides a common repository for building JDBC Driver images to extend existing JBoss EAP Openshift images using S2I.

## Build a driver image of your choice

### Drivers publicly available

If a driver can be publicly downloaded it has a default value for the ARTIFACT_MVN_REPO argument

```bash
# Build mariadb using a tag with the version
$ docker build -f mariadb-driver-image/Dockerfile -t mariadb-driver-image:12.2 .
```

### Drivers not publicly available

In such case, place the JDBC driver inside the directory of the image you want do build, example?

```bash
$ cp ~/Downloads/jconn4-16.0_PL05.jar sybase-driver-image/
$ docker build -f sybase-driver-image/Dockerfile -t sybase-driver-image:16.0_PL05 .
```

About how to use a extension image see [this](../README.md#how-to-use-the-extension-images) section.
