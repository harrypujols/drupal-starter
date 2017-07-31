#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
PORT=$2

# update / upgrade
sudo apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# symlink site's folder
sudo ln -s /var/www/html /home/vagrant/public

# install php latest
sudo apt-get install -y php libapache2

# install composer
sudo apt-get install -y zip unzip composer

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server php-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin
sudo phpenmod mcrypt

# setup mysql user
MY=$(cat <<EOF
[client]
user=root
password=root
host=localhost
EOF
)
echo "${MY}" > /home/vagrant/.my.cnf

# install drush
sudo apt-get install -y drush

# install drupal console
curl https://drupalconsole.com/installer -L -o drupal.phar
sudo mv drupal.phar /usr/local/bin/drupal
sudo chmod +x /usr/local/bin/drupal

# create a database
mysql --user=$PASSWORD --password=$PASSWORD -e "create database ${PROJECT};"

# # install drupal if not present
if [ ! "$( ls -A /var/www/html )" ]; then
  drush dl drupal --drupal-project-rename=html
  sudo rm /var/www/html
  sudo mv html /var/www/html
fi

# install apache
sudo apt-get install -y apache2

# enable mods
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod include

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $PROJECT.local
	  ServerAlias www.$PROJECT.local
    DocumentRoot /var/www/html
    <Directory "/var/www/html">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

echo "${VHOST}" > /etc/apache2/sites-available/$PROJECT.local.conf
sudo a2ensite $PROJECT.local.conf

# change apache configurations
sudo sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/apache2.conf

# restart apache
sudo service apache2 restart

# install git
sudo apt-get -y install git

# all done
echo "database \"$PROJECT\" created"
echo "username is \"$PASSWORD\" password is \"$PASSWORD\""
printf "\033[0;36m${PROJECT} site running on \033[0;35mhttp://localhost:${PORT}\033[0m"
