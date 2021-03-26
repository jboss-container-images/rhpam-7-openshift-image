# JBoss KIE JDBC Driver Extension Images - CEKit

## Before you begin

To interact with this repo you should install the CEKit 3.8.0 or higher:

#### Installing and Configure CEKit
In this section you'll , step by step, how to install CEKit on Fedora, for other systems please refer to the documentation: 
To be possible to install the CEKit using dnf, we need to enable it's dnf repository:

Install [CEKit](https://docs.cekit.io/en/latest/handbook/installation/instructions.html#other-systems) 3.8 using virtualenv: 

To install, see the following commands:

```bash
$ mkdir ~/cekit-3.8
$ virtualenv ~/cekit-3.8
$ source ~/cekit-3.8/bin/activate # tip create an alias for it, e.g. activate-cekit-3.8
$ pip install cekit==3.8.0 
$ pip install odcs docker docker-squash behave
```


## Building an extension image

After you have installed CEKit, all you need to do is execute ```make``` passing
as parameter the desired option, press `tab` for auto completion, see the example below: 

```bash
make mysql
```

This command will build the mysql extension image with the jdbc driver version 8.0.12.

The artifacts to build the db2, mysql, mariadb, postgresql and mssql are available on maven central.

See the examples below on how to build the other extension images:

If you want to specify a custom artifact, use the *artifact* and *version* variables within make command:

```bash
make db2 artifact=/tmp/db2-jdbc-driver.jar version=10.1
```

### Build MySQL

```bash
make mysql
```

### Build MariaDB

```bash
make mariadb
```

### Build PostgreSQL

```bash
make postgresql
```

### Build MS SQL

```bash
make mssql
```

### Build Oracle DB

Oracle extension image requires you to provide the jdbc jar:

```bash
make oracle artifact=/tmp/ojdbc7.jar version=7.0
```

### Build DB2

DB2 extension image requires you to provide the jdbc jar:

```bash
make db2 artifact=/tmp/db2jcc4.jar version=10.2
```

### Build Sybase

Sybase extension image requires you to provide the jdbc jar:

```bash
make sybase artifact=/tmp/jconn4-16.0_PL05.jar version=16.0_PL05
```

If for you need to update the driver xa class or driver class export the `DRIVER_CLASS` or `DRIVER_XA_CLASS` environment
with the desired class, e.g.:

```bash
export DRIVER_CLASS=another.class.Sybase && make sybase artifact=/tmp/jconn4-16.0_PL05.jar version=16.0_PL0
```

About how to use a extension image see [this](../README.md#how-to-use-the-extension-images) section.

If you find any issue feel free to drop an email to bsig-cloud@redhat.com or fill an [issue](https://issues.jboss.org/projects/RHPAM)
