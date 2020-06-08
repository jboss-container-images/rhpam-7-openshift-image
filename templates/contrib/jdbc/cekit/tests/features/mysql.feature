@kiegroup/jboss-kie-mysql-extension-openshift-image
Feature: Verify if MySQL Extension image was correctly built.

  Scenario: Verify if the correct correct files are present in the container and if its content are correct
    When container is started with command bash
    Then file /extensions/install.properties should exist
    And file /extensions/install.sh should exist
    And file /extensions/modules/com/mysql/main/module.xml should exist
    And file /extensions/install.properties should contain DRIVERS=MYSQL
    And file /extensions/install.properties should contain MYSQL_DRIVER_NAME=mysql
    And file /extensions/install.properties should contain MYSQL_DRIVER_MODULE=com.mysql
    And file /extensions/install.properties should contain MYSQL_DRIVER_CLASS=com.mysql.cj.jdbc.Driver
    And file /extensions/install.properties should contain MYSQL_XA_DATASOURCE_CLASS=com.mysql.cj.jdbc.MysqlXADataSource
    And file /extensions/modules/com/mysql/main/module.xml should contain <module xmlns="urn:jboss:module:1.5" name="com.mysql">