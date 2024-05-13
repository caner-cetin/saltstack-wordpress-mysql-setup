#!/bin/bash  
if [ -z "$1" ]; then
  echo "Please provide the master IP address."
  echo "Usage: $0 <master-ip> <minion-name>"
  exit 1
fi
if [ -z "$2" ]; then
  echo "Please provide the minion name."
  echo "Usage: $0 <master-ip> <minion-name>"
  exit 1
fi
curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io
chmod +x bootstrap-salt.sh
sudo ./bootstrap-salt.sh
mkdir -p /etc/salt/minion.d
# define the name of minion
sudo touch /etc/salt/minion.d/master.conf
echo $2 | sudo tee /etc/salt/minion_id
# define the master ip address
echo "master: $1" | sudo tee /etc/salt/minion.d/master.conf
# restart with new config 
sudo service salt-minion restart