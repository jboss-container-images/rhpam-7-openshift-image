@kiegroup/jboss-kie-sybase-extension-openshift-image
Feature: Verify if Sybase Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/com/sybase/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=SYBASE
    And file /extensions/install.properties should contain SYBASE_DRIVER_NAME=sybase
    And file /extensions/install.properties should contain SYBASE_DRIVER_MODULE=com.sybase
    And file /extensions/install.properties should contain SYBASE_DRIVER_CLASS=com.sybase.jdbc2.jdbc.SybDataSource
    And file /extensions/install.properties should contain SYBASE_XA_DATASOURCE_CLASS=com.sybase.jdbc3.jdbc.SybXADataSource
    And file /extensions/modules/com/sybase/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="com.sybase">