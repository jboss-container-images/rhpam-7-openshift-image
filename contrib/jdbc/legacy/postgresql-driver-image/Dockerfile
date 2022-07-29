FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="PostgreSQL JDBC Driver" \
        version="42.2.5"

ARG ARTIFACT_MVN_REPO=https://repo1.maven.org/maven2

COPY install.sh postgresql-driver-image/install.properties /extensions/
COPY postgresql-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar \
    /extensions/modules/system/layers/openshift/org/postgresqlCustom/main/postgresql-42.2.5.jar