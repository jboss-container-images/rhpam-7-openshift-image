FROM scratch

LABEL   maintainer="rromerom@redhat.com" \
        name="Microsoft SQL Server JDBC Driver" \
        version="4.0"

ARG ARTIFACT_MVN_REPO=http://clojars.org/repo

COPY install.sh mssql-driver-image/install.properties /extensions/
COPY mssql-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/com/microsoft/sqlserver/sqljdbc4/4.0/sqljdbc4-4.0.jar \
    /extensions/modules/system/layers/openshift/com/microsoft/main/sqljdbc4.jar