#!/bin/bash
Install_hhvm()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf

#src_url=http://dl.hhvm.com/debian/pool/main/h/hhvm/hhvm_3.1.0~wheezy_amd64.deb && Download_src
src_url=http://sg.hhvm.mirrors.simon.geek.nz/debian/pool/main/h/hhvm/hhvm_3.3.0~wheezy_amd64.deb && Download_src
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add -
echo deb http://dl.hhvm.com/debian wheezy main | tee /etc/apt/sources.list.d/hhvm.list
apt-get update
apt-get -y install hhvm
apt-get -y install libgmp-dev libmemcachedutil2
/usr/share/hhvm/install_fastcgi.sh 
update-rc.d hhvm defaults 
apt-get -y remove hhvm
dpkg -i hhvm_3.3.0~wheezy_amd64.deb
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

mv /etc/mysql/my.cnf{,_bk}

}
