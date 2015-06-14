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
sudo apt-get -y install mesos marathon

#configure zookeeper cluster
sudo cp /vagrant/config/myid /etc/zookeeper/myid
sudo cp /vagrant/config/zoo.cfg /etc/zookeeper/zoo.cfg
sudo cp /vagrant/config/zk /etc/mesos/zk

sudo cp /vagrant/config/masterip /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname

sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk
sudo sed -i 's/mesos/marathon/g' /etc/marathon/conf/zk

#DOCKER LAST
wget -qO- https://get.docker.com/ | sh
echo 'docker,mesos' > containerizers && sudo cp containerizers /etc/mesos-slave/containerizers && rm containerizers
echo '40mins' > executor_registration_timeout && sudo cp executor_registration_timeout /etc/mesos-slave/executor_registration_timeout && rm executor_registration_timeout
if [ -f /vagrant/config/.dockercfg ]; then
  cp /vagrant/config/.dockercfg /home/vagrant/config/.dockercfg #use mesos way to inject docker config. see documentation
fi

#CREATE MARATHON ARTIFACT_STORE AND PUT .dockercfg into
sudo mkdir -p /etc/marathon/store
sudo cp /vagrant/config/artifact_store /etc/marathon/conf/artifact_store
sudo service marathon restart
if [ -f /vagrant/config/.dockercfg ]; then
  cp /vagrant/config/.dockercfg /home/vagrant/.dockercfg
  curl -F "name=file" -F "filename=.dockercfg" -F "file=@.dockercfg" http://192.168.43.10:8080/v2/artifacts
    #check -> curl http://192.168.43.10:8080/v2/artifacts/.dockercfg

    #REF .dockercfg like this:
    #  "uris": ["http://marathon-ip:8080/v2/artifacts/.dockercfg"]
fi

#TODO: install chronos from marathon app script

#start services
sudo service zookeeper restart
sudo service mesos-slave stop
sudo sh -c "echo manual > /etc/init/mesos-slave.override"
sudo service mesos-master restart
sudo service marathon restart

export MASTER=$(mesos-resolve `cat /etc/mesos/zk` 2>/dev/null)
export MARATHON=$(echo $MASTER | sed 's/5050/8080/g')

#install haproxy (bamboo https://github.com/QubitProducts/bamboo ??) #TODO: move haproxy to docker...
sudo apt-get install haproxy
wget https://raw.githubusercontent.com/mesosphere/marathon/master/bin/haproxy-marathon-bridge
chmod 755 haproxy-marathon-bridge
./haproxy-marathon-bridge install_haproxy_system $MARATHON


echo "master setup completed!"
