#!/bin/bash

# Setup
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Add the repository
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update

#install
sudo apt-get -y install mesos

#disable zookeeper
sudo service zookeeper stop
sudo sh -c "echo manual > /etc/init/zookeeper.override"

#configure
sudo cp /vagrant/config/zk /etc/mesos/zk

#disable master
sudo service mesos-master stop
sudo sh -c "echo manual > /etc/init/mesos-master.override"

#configure
echo $1 | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

#DOCKER LAST
wget -qO- https://get.docker.com/ | sh
echo 'docker,mesos' > containerizers && sudo cp containerizers /etc/mesos-slave/containerizers && rm containerizers
echo '5mins' > executor_registration_timeout && sudo cp executor_registration_timeout /etc/mesos-slave/executor_registration_timeout && rm executor_registration_timeout
cp /vagrant/.dockercfg /home/vagrant/config/.dockercfg #use mesos way to inject docker config. see documentation

#install haproxy
#echo deb http://archive.ubuntu.com/ubuntu trusty-backports main universe | \
#sudo tee /etc/apt/sources.list.d/backports.list
#apt-get update
#apt-get install haproxy -t trusty-backports

#start slave
sudo service mesos-slave restart

echo "slave setup completed!"
