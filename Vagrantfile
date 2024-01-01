# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/8"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    end
  config.vm.provision "file", source: "./conf/", destination: "/tmp/"
  config.vm.provision "shell", inline: File.read("watchdog.sh")
  config.vm.provision "shell", inline: <<-SHELL
        sudo cp /tmp/conf/httpd-first /etc/sysconfig
        sudo cp /tmp/conf/httpd-second /etc/sysconfig
        sudo cp /tmp/conf/httpd@first.service /etc/systemd/system
        sudo cp /tmp/conf/httpd@second.service /etc/systemd/system
        sudo cp /tmp/conf/first.conf /etc/httpd/conf
        sudo cp /tmp/conf/second.conf /etc/httpd/conf
        sudo systemctl start httpd@first
        sudo systemctl start qhttpd@second
  SHELL

end