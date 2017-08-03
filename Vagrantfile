# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT='drupal'
PORT='8080'

Dir.mkdir(PROJECT) unless File.exists?(PROJECT)

Vagrant.configure('2') do |config|
  config.vm.box = 'harrypujols/sandbox'
  config.vm.network 'forwarded_port', guest: 80, host: PORT
  config.vm.network 'forwarded_port', guest: 10000, host: 10000
  config.vm.synced_folder './' + PROJECT, '/var/www/html', :mount_options => ['dmode=777','fmode=666']
  config.vm.provision :shell, path: 'provision.sh', args: PROJECT + " " + PORT
end
