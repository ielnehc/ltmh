#!/bin/bash

Install_hhvm()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf

#src_url=http://dl.hhvm.com/ubuntu/pool/main/h/hhvm/hhvm_3.1.0~trusty_amd64.deb && Download_src
src_url=http://sg.hhvm.mirrors.simon.geek.nz/ubuntu/pool/main/h/hhvm/hhvm_3.3.0~trusty_amd64.deb && Download_src
wget -O - http://mirror.mephi.ru/hhvm/conf/hhvm.gpg.key | apt-key add -
echo deb http://mirror.mephi.ru/hhvm/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list
apt-get update
apt-get -y install libgnutls26
wget -c http://security.ubuntu.com/ubuntu/pool/main/libm/libmemcached/libmemcached10_1.0.8-1ubuntu2_amd64.deb
wget -c http://mirrors.kernel.org/ubuntu/pool/main/r/rtmpdump/librtmp0_2.4+20121230.gitdf6c518-1_amd64.deb
dpkg -i libmemcached10_1.0.8-1ubuntu2_amd64.deb
dpkg -i librtmp0_2.4+20121230.gitdf6c518-1_amd64.deb
apt-get -y install libgmp-dev libmemcachedutil2 
apt-get -y install hhvm
/usr/share/hhvm/install_fastcgi.sh
update-rc.d hhvm defaults 
apt-get -y remove hhvm
dpkg -i hhvm_3.3.0~trusty_amd64.deb
/usr/share/hhvm/install_fastcgi.sh 
update-rc.d hhvm defaults 
service hhvm stop
/bin/rm -f /etc/hhvm/server.ini
cd ..
/bin/cp conf/server.ini /etc/hhvm/server.ini
#service hhvm restart 
cat >> /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /tmp/mysql.sock
memory_limit = 256M
post_max_size = 50M 
EOF

rm -rf libmemcached10_1.0.8-1ubuntu2_amd64.deb
rm -rf librtmp0_2.4+20121230.gitdf6c518-1_amd64.deb
rm -rf hhvm_3.3.0~trusty_amd64.deb
mv /etc/mysql/my.cnf{,_bk}

}
