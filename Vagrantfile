# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT='public'
PORT='8080'

Dir.mkdir(PROJECT) unless File.exists?(PROJECT)

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.network 'forwarded_port', guest: 80, host: PORT
  config.vm.network :forwarded_port, guest: 22, host: 2201, id: 'ssh', auto_correct: true
  config.vm.synced_folder './' + PROJECT, '/var/www/html', :mount_options => ['dmode=777','fmode=666']
  config.vm.provision :shell, path: 'provision.sh', args: PROJECT + " " + PORT
end
