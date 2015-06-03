# mesos-cluster-playground
My playground for testing mesos cluster using vagrant

#Start
install last version of both vagrant and vmware and run vagrant up from the root of the repository


#Cluster (1 master, 1 zookeeper, 1 marathon, 2/3 slaves)
- master: contains zookeeper, mesos-master, mesos-slave (not running by default), artifact-store
- slave: contains mesos-slave
- slave1: contains mesos-slave
- all machine contains docker configured to be runnable throught marathon
- chronos has been setup in order to run into the cluster using marathon

In order to run the slave from the master node connect to the master using vagrant ssh master and type command sudo service master-slave start

#Web GUI
- Mesos: http://192.168.43.10:5050
- Marathon: http://192.168.43.10:8080
