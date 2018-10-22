@kiegroup/jboss-kie-oracle-extension-openshift-image
Feature: Verify if Oracle Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/com/oracle/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=ORACLE
    And file /extensions/install.properties should contain ORACLE_DRIVER_NAME=oracle
    And file /extensions/install.properties should contain ORACLE_DRIVER_MODULE=com.oracle
    And file /extensions/install.properties should contain ORACLE_DRIVER_CLASS=oracle.jdbc.driver.OracleDriver
    And file /extensions/install.properties should contain ORACLE_XA_DATASOURCE_CLASS=oracle.jdbc.xa.client.OracleXADataSource
    And file /extensions/modules/com/oracle/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="com.oracle">