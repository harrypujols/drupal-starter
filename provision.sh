#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
PORT=$2

# update / upgrade
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# install php latest
apt-get install -y php libapache2

# install composer
apt-get install -y zip unzip composer

# install mysql and give password to installer
debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
apt-get -y install mysql-server php-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
apt-get -y install phpmyadmin
phpenmod mcrypt

# setup mysql user
MY=$(cat <<EOF
[client]
user=root
password=root
host=localhost
EOF
)
echo "$MY" > /home/vagrant/.my.cnf

# install drush
apt-get install -y drush

# install drupal console
curl https://drupalconsole.com/installer -L -o drupal.phar
mv drupal.phar /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal

# create a database
mysql --user=$PASSWORD --password=$PASSWORD -e "create database $PROJECT;"

# install apache
apt-get install -y apache2

# enable mods
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod include

# change apache configurations
sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/apache2.conf

# install drupal if not present
if [ ! -f /var/www/html/index.php  ]; then
  rm /var/www/html/index.html
  drush dl drupal-8 --destination=/var/www/ --drupal-project-rename=$PROJECT
  rsync -vau --delete-after /var/www/$PROJECT/ /var/www/html/
  rm -rf /var/www/$PROJECT
fi

# symlink site's folder
ln -s /var/www/html /home/vagrant/$PROJECT

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/$PROJECT"
    <Directory "/var/www/$PROJECT">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-available/default.conf

# restart apache
service apache2 restart

# install git
apt-get -y install git

# all done
echo "database \"$PROJECT\" created"
echo "username is \"$PASSWORD\" password is \"$PASSWORD\""
printf "\033[0;36m$PROJECT site running on \033[0;35mhttp://localhost:$PORT\033[0m"
