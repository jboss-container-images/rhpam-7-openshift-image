@kiegroup/jboss-kie-mssql-extension-openshift-image
Feature: Verify if MSSQL Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/com/microsoft/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=MSSQL
    And file /extensions/install.properties should contain MSSQL_DRIVER_NAME=mssql
    And file /extensions/install.properties should contain MSSQL_DRIVER_MODULE=com.microsoft
    And file /extensions/install.properties should contain MSSQL_DRIVER_CLASS=com.microsoft.sqlserver.jdbc.SQLServerDriver
    And file /extensions/install.properties should contain MSSQL_XA_DATASOURCE_CLASS=com.microsoft.sqlserver.jdbc.SQLServerXADataSource
    And file /extensions/modules/com/microsoft/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="com.microsoft">