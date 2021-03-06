#!/bin/bash

set -o errexit
set -e -o pipefail

echo "vagrant provision: $0"

# https://serverfault.com/a/500778/119512
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure --frontend=noninteractive locales

# run.sh (in metacpan-puppet) won't run until this is done:
hosts_line="127.0.0.1    puppet"
grep -F "$hosts_line" /etc/hosts || echo $'\n\n# puppet (run.sh)\n'"$hosts_line" >> /etc/hosts

DEB=puppet-release-stretch.deb
cd /tmp
wget https://apt.puppetlabs.com/$DEB -O $DEB
dpkg -i $DEB

apt-get update

apt-get -q --assume-yes install dirmngr vim sudo openssh-server git aptitude
apt-get -q --assume-yes install puppetmaster puppet

# We don't want puppet running automatically
update-rc.d puppet disable; /etc/init.d/puppet stop

cd /etc
# Maybe clean out package files
if [ ! -d /etc/puppet/.git ]; then
  rm -rf /etc/puppet
fi
