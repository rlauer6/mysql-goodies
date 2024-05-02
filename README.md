# Overview

This is the README file for the `mysql-goodies` repository.

This repo contains utilities and artifacts, tips and tricks that *may*
be useful for Perl developers using MySQL. This is a WIP.

## MySQL 8

In October of 2023, version 5.7 of MySQL reached EOL status.  Version
5.7 will no longer receive updates. Accordingly, most applications
using MySQL will want to migration to version 8.

[Changes in MySQL
8.0](https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html)

Checking your database for potential issues prior to upgrading is
recommmended.  A utility for performing this check can be found
[here](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-upgrade.html).

## `caching-sha2-pluggable-authentication`

One of the first issues you may encounter when attempting to connect
to a MySQL server is authentication. MySQL 8 uses a different plugin
for authentication. Details can be found here:

[caching-sha2-pluggable-authentication](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html)

Unless you are using a client that supports the plugin and using SSL
connections you must turn off that default plugin and use the
`mysql_native_password` plugin.  To force the MySQL 8 container to use
that add this to the `docker-compose.yml` file.

```
command: --default-authentication-plugin=mysql_native_password
```

## Building a MySQL 8 Compatible `DBD::mysql`

Requires:

* `make`
* `docker`

In order to use MySQL 8 with Perl you need to use version 5 and above
of `DBD::mysql`. Building version 5+ requires the MySQL 8 client
libraries. A Docker file (`Dockerfile.mysql8`) can be found in this
directory which will build an RPM containing the latest version of the
`DBD::mysql` driver.

To create the RPMs just run `make` in the root of the repository.

```
make
```

Additionally, you will need to install the MySQL client libraries on
any server or in any container you use with this version of
`DBD::mysql`. You install the latest RPMs for the client libraries as
shown below:

```
yum install -y https://dev.mysql.com/get/mysql84-community-release-el7-1.noarch.rpm
yum install -y mysql-community-client  mysql-community-devel
```

# MySQL 5.7

Although MySQL 5.7 had an EOL of 10/2023 you may still be running it!
And if you are running an RDS in AWS using 5.7 you probably know by
now that you are being whacked with ridiculous up-charge for "extended
support" - even if you are not on a support plan with AWS.

The increased fees can be steep, e.g.:

| Type | Month | Cost |
| t3.small | Jan 2024 | $30.30 |
| t3.small | Jan 2024 | $173.48 |

Running a unmanaged t3.small running the community edition 5.7.44
would cost $14.98, a savings for over $150/month.

So...in case you want to spark up your own database server...

## MySQL 5.7 Yum Repository

```
[mysql57]
baseurl=https://yum.oracle.com/repo/OracleLinux/OL7/MySQL57_community/x86_64/
enabled=1
gpgcheck=0
```

## Install

```
yum install -y mysql-community-server
```

Start the server...

```
systemctl start mysqld
```

Get the root password

```
mysql_pw=$(sudo grep -ri 'generated for root' /var/log/mysqld.log | \
  tail -1 | perl -ne '$a=(split /\s+/, $_)[-1]; print $a;')
```

Update the root password

```
echo "alter user 'root'@'localhost' identified by "new-password" | \
mysql -u root --password="$mysql_pw"
```

Add a new Super user

```
echo "grant all privileges on *.* to 'super-user'@'%' identified by 'some-password' | \
mysql -u root --password="$mysql_pw"
```

## Password Validation

https://dev.mysql.com/doc/refman/8.0/en/validate-password-options-variables.html

```
show variables like 'validate_password%';
set global validate_password_special_char_count=0;
```
