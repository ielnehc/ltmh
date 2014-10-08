#!/bin/bash

Install_hhvm()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf

# rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
# wget http://www.hop5.in/yum/el6/hop5.repo
# mv hop5.repo  /etc/yum.repos.d
# yum clean all
# yum -y remove  libevent-devel libevent 
# yum -y install hhvm-3.2.0  --setopt=protected_multilib=false
#/usr/share/hhvm/install_fastcgi.sh 
#update-rc.d hhvm defaults 
#
useradd -M -s /sbin/nologin www-data
chown -R www-data:www-data  /var/run/hhvm/ 
/bin/rm -f /etc/init.d/hhvm
/bin/rm -f /etc/hhvm/server.ini
cd ..
/bin/cp init/HHVM-init-CentOS /etc/init.d/hhvm
/bin/cp conf/server.ini /etc/hhvm/server.ini
chmod +x /etc/init.d/hhvm
cat >> /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /tmp/mysql.sock
memory_limit = 256M
post_max_size = 50M 
EOF
#service hhvm restart 
chkconfig hhvm on
}
