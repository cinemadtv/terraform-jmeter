#!/bin/bash

set -e

echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -qq
sudo apt-get install -y -qq oracle-java8-installer
cd /tmp
wget https://www.apache.org/dist/jmeter/binaries/apache-jmeter-3.3.tgz
wget https://www.apache.org/dist/jmeter/binaries/apache-jmeter-3.3.tgz.md5
md5sum -c apache-jmeter-3.3.tgz.md5
sudo rm -rf /opt/jmeter
sudo mkdir -p /opt/jmeter
sudo tar -xf apache-jmeter-3.3.tgz -C /opt/jmeter --strip-components=1
sudo rm -rf apache-jmeter-3.3.tgz*
