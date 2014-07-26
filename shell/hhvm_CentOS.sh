
Install_hhvm()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf

src_url=http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && Download_src
src_url=http://dheche.fedorapeople.org/hhvm/el6/RPMS/x86_64/hhvm-release-6-1.noarch.rpm && Download_src

rpm -ivh epel-release-6-8.noarch.rpm
rpm -ivh hhvm-release-6-1.noarch.rpm
yum install -y hhvm
#/usr/share/hhvm/install_fastcgi.sh 
#update-rc.d hhvm defaults 
service hhvm restart 
}
