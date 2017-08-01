# drupal-starter
A quick Drupal stack for Vagrant/Virtualbox

## Installation

This repository needs two dependencies to install:
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [Virtual Box](https://www.virtualbox.org/wiki/Downloads)

Once install, use the command line to reach the root of this repository. From there run:

```bash
vagrant up
```

Then, get a cup of coffee and sit back. The first run will take a few minutes.

## Settings
Your drupal will be available in the folder "public".
The default settings are:

**URL:** http://localhost:8080

**Database Name:** public

**Database User:** root

**Database Password:** root


For easy access to the database, phpmyadmin is installed. Log in at http://localhost:8080/phpmyadmin --User is "root", password is "root"

All these settings can be tinkered by playing with the Vagrantfile and provision.sh

Drush, Drupal Console, and other backend goodies can be accessed by connecting to the Ubuntu server, using:

```bash
vagrant ssh
```

To install Drupal 7, any other version of Drupal, or an instance of Drupal you have modified, just replace the "public" folder.
