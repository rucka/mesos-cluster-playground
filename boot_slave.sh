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
echo '40mins' > executor_registration_timeout && sudo cp executor_registration_timeout /etc/mesos-slave/executor_registration_timeout && rm executor_registration_timeout
if [ -f /vagrant/config/.dockercfg ]; then
  cp /vagrant/config/.dockercfg /home/vagrant/config/.dockercfg #use mesos way to inject docker config. see documentation
fi

#start slave
sudo service mesos-slave restart

export MASTER=$(mesos-resolve `cat /etc/mesos/zk` 2>/dev/null)
export MARATHON=$(echo $MASTER | sed 's/5050/8080/g')

#install haproxy (bamboo https://github.com/QubitProducts/bamboo ??) #TODO: move haproxy to docker...
sudo apt-get install haproxy
wget https://raw.githubusercontent.com/mesosphere/marathon/master/bin/haproxy-marathon-bridge
chmod 755 haproxy-marathon-bridge
./haproxy-marathon-bridge install_haproxy_system $MARATHON


echo "slave setup completed!"
