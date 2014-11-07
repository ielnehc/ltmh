#!/bin/bash

Install_hhvm()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf


#
yum -y remove hhvm
yum --nogpgcheck -y install libbson
wget -c http://soft.hhvmc.com/dl/centos6/hhvm-stable-3.3.0-1.el6.x86_64.rpm
rpm -ivh hhvm-stable-3.3.0-1.el6.x86_64.rpm
useradd -M -s /sbin/nologin www
chown -R www:www  /var/run/hhvm/ 
/bin/rm -f /etc/init.d/hhvm
/bin/rm -f /etc/hhvm/server.ini
cd ..
/bin/cp init/HHVM-init-CentOS /etc/init.d/hhvm
/bin/cp conf/server.ini /etc/hhvm/server.ini
chmod +x /etc/init.d/hhvm
rm -rf hhvm-stable-3.3.0-1.el6.x86_64.rpm
cat >> /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /tmp/mysql.sock
memory_limit = 256M
post_max_size = 50M 
EOF
#service hhvm restart 
chkconfig hhvm on
}

