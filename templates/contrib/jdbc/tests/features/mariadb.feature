@kiegroup/jboss-kie-mariadb-extension-openshift-image
Feature: Verify if MariaDB Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/org/mariadbCustom/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=MARIADB
    And file /extensions/install.properties should contain MARIADB_DRIVER_NAME=mariadbCustom
    And file /extensions/install.properties should contain MARIADB_DRIVER_MODULE=org.mariadbCustom
    And file /extensions/install.properties should contain MARIADB_DRIVER_CLASS=org.mariadb.jdbc.Driver
    And file /extensions/install.properties should contain MARIADB_XA_DATASOURCE_CLASS=org.mariadb.jdbc.MariaDbDataSource
    And file /extensions/modules/org/mariadbCustom/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="org.mariadbCustom">
