FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="MySQL JDBC Driver" \
        version="8.0.12"

ARG ARTIFACT_MVN_REPO=https://repo1.maven.org/maven2

COPY install.sh mysql-driver-image/install.properties /extensions/
COPY mysql-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/mysql/mysql-connector-java/8.0.12/mysql-connector-java-8.0.12.jar \
    /extensions/modules/system/layers/openshift/com/mysql/main/mysql-connector-java.jar