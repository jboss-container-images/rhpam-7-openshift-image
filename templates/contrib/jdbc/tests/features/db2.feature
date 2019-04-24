@kiegroup/jboss-kie-db2-extension-openshift-image
Feature: Verify if DB2 Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/com/ibm/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=DB2
    And file /extensions/install.properties should contain DB2_DRIVER_NAME=db2
    And file /extensions/install.properties should contain DB2_DRIVER_MODULE=com.ibm
    And file /extensions/install.properties should contain DB2_DRIVER_CLASS=com.ibm.db2.jcc.DB2Driver
    And file /extensions/install.properties should contain DB2_XA_DATASOURCE_CLASS=com.ibm.db2.jcc.DB2XADataSource
    And file /extensions/modules/com/ibm/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="com.ibm">