FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="MariaDB JDBC Driver" \
        version="2.4.0"

ARG ARTIFACT_MVN_REPO=https://repo1.maven.org/maven2

COPY install.sh mariadb-driver-image/install.properties /extensions/
COPY mariadb-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/org/mariadb/jdbc/mariadb-java-client/2.4.0/mariadb-java-client-2.4.0.jar \
    /extensions/modules/system/layers/openshift/org/mariadb/main/mariadb-java-client.jar