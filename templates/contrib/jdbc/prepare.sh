#!/usr/bin/env bash

# This script is used by Makefile to prepare the install.properties and the
# db-overrides.yaml file
# requires: envsubst

command -v envsubst > /dev/null
if [ $? != 0 ]; then
    echo "Command envsubst not found"
    exit 1
fi

prepareFiles() {
    export DRIVERS DRIVER_NAME DRIVER_MODULE DRIVER_CLASS DRIVER_XA_CLASS DRIVER_DIR DRIVER_JDBC_ARTIFACT_NAME \
    DATABASE_TYPE VERSION
    env | egrep "DRIVER|DATABASE"
    cat modules/kie-custom-jdbc-driver/base-module.yaml | envsubst > modules/kie-custom-jdbc-driver/module.yaml
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then echo "file modules/kie-custom-jdbc-driver/module.yaml successfully generated."; else echo "failed to create modules/kie-custom-jdbc-driver/module.yaml"; fi
    cat modules/kie-custom-jdbc-driver/added/base_install.properties | envsubst > modules/kie-custom-jdbc-driver/added/install.properties
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then echo "file install.properties successfully generated."; else echo "failed to create install.properties"; fi
    cat modules/kie-custom-jdbc-driver/added/base_module.xml | envsubst > modules/kie-custom-jdbc-driver/added/module.xml
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then echo "file module.xml successfully generated."; else echo "failed to create module.xml"; fi
    cat base-db-overrides.yaml | envsubst > db-overrides.yaml
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then echo "file db-overrides.yaml successfully generated."; else echo "failed to create db-overrides.yaml"; fi
}


finalizeConfiguration() {
    ARTIFACT="${1}"
    VERSION="${2}"
    if [ "${VERSION}x" = "x" ] || [ "${ARTIFACT}x" = "x" ]; then
        echo "Version or artifact cannot be empty"
        exit 1
    else
        if [ ! -f "${ARTIFACT}" ]; then
            echo "File ${ARTIFACT} not found"
            exit 1
        fi

        DRIVER_JDBC_ARTIFACT_NAME="$(basename ${ARTIFACT})"

        prepareFiles

        echo "
artifacts:
  - url: file://${ARTIFACT}
    md5: $(md5sum ${ARTIFACT} | cut -d" " -f1)" >> db-overrides.yaml

    fi

}

case ${1} in
    db2)
        DATABASE_TYPE="db2"

        DRIVERS="DB2"
        DRIVER_NAME="db2"
        DRIVER_MODULE="com.ibm"
        DRIVER_CLASS="com.ibm.db2.jcc.DB2Driver"
        DRIVER_XA_CLASS="com.ibm.db2.jcc.DB2XADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="com/ibm/main"

        # there is a jcc driver for ibm db available on maven central
        # if no parameters found, use it.
        if [ "${2}x" != "x" ] || [ "${3}x" != "x" ]; then
            finalizeConfiguration $2 $3

        else
            VERSION="11.1.4.4"
            DRIVER_JDBC_ARTIFACT_NAME="jcc-${VERSION}.jar"
            prepareFiles
            echo "
artifacts:
  - url: https://repo1.maven.org/maven2/com/ibm/db2/jcc/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}
    md5: $(curl -s https://repo1.maven.org/maven2/com/ibm/db2/jcc/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}.md5)" >> db-overrides.yaml

        fi


    ;;
    mariadb)
        DATABASE_TYPE="mariadb"
        VERSION="2.4.0"
        DRIVERS="MARIADB"
        DRIVER_NAME="mariadbCustom"
        DRIVER_MODULE="org.mariadbCustom"
        DRIVER_CLASS="org.mariadb.jdbc.Driver"
        DRIVER_XA_CLASS="org.mariadb.jdbc.MariaDbDataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="org/mariadbCustom/main"
        DRIVER_JDBC_ARTIFACT_NAME="mariadb-java-client-${VERSION}.jar"

        prepareFiles

        echo "
artifacts:
  - url: https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}
    md5: $(curl -s https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}.md5)" >> db-overrides.yaml

    ;;
    mssql)
        DATABASE_TYPE="mssql"
        VERSION="7.2.2.jre11"
        DRIVERS="MSSQL"
        DRIVER_NAME="mssql"
        DRIVER_MODULE="com.microsoft"
        DRIVER_CLASS="com.microsoft.sqlserver.jdbc.SQLServerDriver"
        DRIVER_XA_CLASS="com.microsoft.sqlserver.jdbc.SQLServerXADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="com/microsoft/main"
        DRIVER_JDBC_ARTIFACT_NAME="mssql-jdbc-${VERSION}.jar"

        prepareFiles

        echo "
artifacts:
  - url: https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}
    md5: $(curl -s https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}.md5)" >> db-overrides.yaml

    ;;
    mysql)
        DATABASE_TYPE="mysql"
        VERSION="8.0.12"
        DRIVERS="MYSQL"
        # needs to update after the default jdbc driver is dropped of frm eap images
        DRIVER_NAME="mysql"
        DRIVER_MODULE="com.mysql"
        DRIVER_CLASS="com.mysql.cj.jdbc.Driver"
        DRIVER_XA_CLASS="com.mysql.cj.jdbc.MysqlXADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="com/mysql/main"
        DRIVER_JDBC_ARTIFACT_NAME="mysql-connector-java-${VERSION}.jar"

        prepareFiles

        echo "
artifacts:
  - url: https://repo1.maven.org/maven2/mysql/mysql-connector-java/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}
    md5: $(curl -s https://repo1.maven.org/maven2/mysql/mysql-connector-java/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}.md5)" >> db-overrides.yaml

    ;;
    oracle)
        DATABASE_TYPE="oracle"
        DRIVERS="ORACLE"
        DRIVER_NAME="oracle"
        DRIVER_MODULE="com.oracle"
        DRIVER_CLASS="oracle.jdbc.driver.OracleDriver"
        DRIVER_XA_CLASS="oracle.jdbc.xa.client.OracleXADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="com/oracle/main"

        finalizeConfiguration $2 $3
    ;;

    sybase)
        DATABASE_TYPE="sybase"
        DRIVERS="SYBASE"
        DRIVER_NAME="sybase"
        DRIVER_MODULE="com.sybase"
        DRIVER_CLASS="com.sybase.jdbc2.jdbc.SybDataSource"
        DRIVER_XA_CLASS="com.sybase.jdbc3.jdbc.SybXADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="com/sybase/main"

        finalizeConfiguration $2 $3
    ;;

    postgresql)
        DATABASE_TYPE="postgresql"
        VERSION="42.2.5"
        DRIVERS="POSTGRESQL"
        # needs to update after the default jdbc driver is dropped of frm eap images
        DRIVER_NAME="postgresqlCustom"
        DRIVER_MODULE="org.postgresqlCustom"
        DRIVER_CLASS="org.postgresql.Driver"
        DRIVER_XA_CLASS="org.postgresql.xa.PGXADataSource"

        # base path is $JBOSS_HOME/modules
        DRIVER_DIR="org/postgresqlCustom/main"
        DRIVER_JDBC_ARTIFACT_NAME="postgresql-${VERSION}.jar"

        prepareFiles

        echo "
artifacts:
  - url: https://repo1.maven.org/maven2/org/postgresql/postgresql/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}
    md5: $(curl -s https://repo1.maven.org/maven2/org/postgresql/postgresql/${VERSION}/${DRIVER_JDBC_ARTIFACT_NAME}.md5)" >> db-overrides.yaml

    ;;
    *)
        echo "Type ${1} is not valid, the accepted values are: db2, mariadb, mssql, mysql, oracle and postgresql"
        echo "Usage: sh prepare.sh DB_TYPE <OPTIONAL>DRIVER_LOCATION VERSION"
        echo "DRIVER_LOCATION, is an optional parameter in case you do have a internal repository where the jdbc jar can be fetched."
        echo "When DRIVER_LOCATION is set the VERSION is mandatory"
        echo "Example: sh prepare.sh oracle /tmp/oracle.jar 7.0.0"
    ;;
esac
