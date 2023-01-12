FROM scratch

LABEL   maintainer="bsig-cloud@redhat.com" \
        name="Microsoft SQL Server JDBC Driver" \
        version="7.2.2.jre11"

ARG ARTIFACT_MVN_REPO=https://repo1.maven.org/maven2

COPY install.sh mssql-driver-image/install.properties /extensions/
COPY mssql-driver-image/modules /extensions/modules/

# Download the driver into the module folder
ADD ${ARTIFACT_MVN_REPO}/com/microsoft/sqlserver/mssql-jdbc/7.2.2.jre11/mssql-jdbc-7.2.2.jre11.jar \
    /extensions/modules/system/layers/openshift/com/microsoft/main/mssql-jdbc-7.2.2.jre11.jar