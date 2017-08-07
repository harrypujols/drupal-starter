#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
PORT=$2

# register packages
add-apt-repository ppa:ondrej/php

# update / upgrade
apt-get update
apt-get upgrade

# add php packages
apt-get install -y php-uploadprogress
phpenmod uploadprogress

# install drush
apt-get install -y drush

# install drupal console
curl https://drupalconsole.com/installer -L -o drupal.phar
mv drupal.phar /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal

# create a database
mysql --user=$PASSWORD --password=$PASSWORD -e "create database $PROJECT;"

# install drupal if not present
if [ ! -f /var/www/html/index.php  ]; then
  rm /var/www/html/index.html
  drush dl drupal-8 --destination=/var/www/ --drupal-project-rename=$PROJECT
  rsync -vau --delete-after /var/www/$PROJECT/ /var/www/html/
  rm -rf /var/www/$PROJECT
fi

# symlink site's folder
ln -s /var/www/html /home/vagrant/$PROJECT

# install node
apt-get install -y npm
npm install -g n
n stable

# restart apache
service apache2 restart

# all done
echo "database \"$PROJECT\" created"
echo "username is \"$PASSWORD\" password is \"$PASSWORD\""
printf "\033[0;36m$PROJECT site running on \033[0;35mhttp://localhost:$PORT\033[0m"
