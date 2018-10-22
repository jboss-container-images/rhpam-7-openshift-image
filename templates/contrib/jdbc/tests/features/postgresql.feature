@kiegroup/jboss-kie-postgresql-extension-openshift-image
  Feature: Verify if PostgreSQL Extension image was correctly built.

    Scenario: Verify if the correct correct files are present in the container and if its content are correct
      When container is started with command bash
      Then file /extensions/install.properties should exist
      And file /extensions/install.sh should exist
      And file /extensions/modules/org/postgresqlCustom/main/module.xml should exist
      And file /extensions/install.properties should contain DRIVERS=POSTGRESQL
      And file /extensions/install.properties should contain POSTGRESQL_DRIVER_NAME=postgresqlCustom
      And file /extensions/install.properties should contain POSTGRESQL_DRIVER_MODULE=org.postgresqlCustom
      And file /extensions/install.properties should contain POSTGRESQL_DRIVER_CLASS=org.postgresql.Driver
      And file /extensions/install.properties should contain POSTGRESQL_XA_DATASOURCE_CLASS=org.postgresql.xa.PGXADataSource
      And file /extensions/modules/org/postgresqlCustom/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="org.postgresqlCustom">