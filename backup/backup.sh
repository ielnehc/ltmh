#!/bin/bash

cd $ltmh_dir/backup
. ../tools/download.sh 
. ../tools/check_os.sh
. ../options.conf


# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#############################################################################
#   LTMH/LNMH/LNMP/LTMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+       #
#   For more information please visit http://www.hhvmc.com/forum-36-1.html    
#       According to the command operation, the backup site data you         
############################################################################"
export LANG=zh_CN.UTF-8
clear

if [ "$1" != "--help" ]; then

	echo ""
	echo "The following need to input some necessary information:"
	read -p "(Please input bucket name:" space
	if [ "$space" = "" ]; then
		echo "Error!"
		echo "Please try it again."
		read -p "(This value is only qiniu and must input):" space
	fi
	echo "==========================="
	echo "bucket name =$space"
	echo "===========================" 
	echo ""

	read -p "Please input Qiniu AccessKey:" qiniuAccessKey
	if [ "$qiniuAccessKey" = "" ]; then
		echo "QINIU AccessKey Error!"
		echo "Please try it again."
		read -p "(This value must be entered correctly):" qiniuAccessKey
	fi
	echo "==========================="
	echo "QINIU AccessKey=$qiniuAccessKey"
	echo "===========================" 
	echo ""

	read -p "Please input Qiniu SecretKey:" qiniuSecretKey
	if [ "$qiniuSecretKey" = "" ]; then
		echo "QINIU SecretKey Error!"
		echo "Please try it again."
		read -p "(This value must be entered correctly):" qiniuSecretKey
	fi
	echo "==========================="
	echo "QINIU SecretKey=$qiniuSecretKey"
	echo "===========================" 
	echo ""
	
	read -p "please enter backup password, the system will automatically use the password backup file encryption and compression:" backup_file_compression_password
	if [ "$backup_file_compression_password" = "" ]; then
		echo "Backup Password Error!"
		echo "Please try it again."
		read -p "(For the safety of your data, this is a must input values):" backup_file_compression_password
	fi
	echo ""
	echo "==========================="
	echo "Backup Password Record success!"
	echo "===========================" 
	echo ""
	
	read -p "Please input need backup database name:" database_name
	if [ "$database_name" = "" ]; then
		echo "Need backup database name Error!"
		echo "Please try it again."
		read -p "Please input need backup database name:" database_name
	fi
	echo "==========================="
	echo "Your input is the name of the database=$database_name"
	echo "===========================" 
	echo ""
	
	read -p "Please enter the database user name, enter the default root:" mysql_user
	if [ "$mysql_user" = "" ]; then
		mysql_user=root
	fi
	echo "==========================="
	echo "mysql_user=$mysql_user"
	echo "===========================" 
	echo ""
	
	read -p "please enter the password in the database(root):" mysql_passwd
	echo ""
	echo "Your input mysql password=$mysql_passwd"
	echo "MYSQL Password Record success"
	echo "===========================" 
	echo ""
	
	echo "Please input Your web data path:"
	read -p "(Default: /home/wwwroot):" home_dir
	if [ "$home_dir" = "" ]; then
		home_dir=/home/wwwroot
	fi
	echo "==========================="
	echo "Your web data path is $home_dir"
	echo "==========================="	
	echo ""

	echo "Please input Your mysqldump path:"
	read -p "(Default: /usr/local/mysql/bin/mysqldump):" mysqldump_dir
	if [ "$mysqldump_dir" = "" ]; then
		mysqldump_dir=/usr/local/mysql/bin/mysqldump
	fi
	echo "==========================="
	echo "Your mysqldump path is $mysqldump_dir"
	echo "==========================="	
	echo ""

	echo "Please input Your nginx's conf or Apache's conf path:"
	read -p "(Default: /usr/local/nginx/conf):" nginx_configuration_file
	if [ "$nginx_configuration_file" = "" ]; then
		nginx_configuration_file=/usr/local/nginx/conf
	fi
	echo "==========================="
	echo "Your nginx's conf or Apache's conf path is $nginx_configuration_file"
	echo "==========================="	
	echo ""

	echo "Please input Your local backup path:"
	read -p "(Default: /home/backup):" local_bankup
	if [ "$local_bankup" = "" ]; then
		local_bankup=/home/backup
	fi
	echo "==========================="
	echo "Your local backup is $local_bankup"
	echo "==========================="	
	echo ""
	
	echo "Please input Your local backup hold time(day):"
	read -p "(Default: 2):" expired_days
	if [ "$expired_days" = "" ]; then
		expired_days=2
	fi
	echo "==========================="
	echo "Your local backup is $expired_days day."
	echo "==========================="	
	echo ""
	
	echo "Please input Your domain:"
	read -p "(Default: hhvmc.com):" domain_name
	if [ "$domain_name" = "" ]; then
		domain_name=hhvmc.com
	fi
	echo "==========================="
	echo "Your domain is $domain_name"
	echo "==========================="	
	echo ""
	
		
	echo "Please input a line crontab:"
	read -p "(Default: 10 3 * * *):" backup_time
	if [ "$backup_time" = "" ]; then
		backup_time="01 00 * * *"
	fi
	echo "==========================="
	echo "Your crontab is $backup_time."
	echo "==========================="	
	echo ""
	
	echo "==========================="
	echo "ok! !"
	echo "Please Wait..."
	echo "==========================="	

if [ ! -d $local_bankup ]; then
	mkdir -p $local_bankup
	chmod -R 777 $local_bankup
	chmod -R 777 $scriptdir
fi
	

con_file=$(date +"%Y%m%d")$domain_name.json
cat >>$scriptdir/$con_file<<eof
{
    "access_key": "$qiniuAccessKey",
    "secret_key": "$qiniuSecretKey",
    "bucket": "$space",
    "sync_dir": "$local_bankup/bf_tmp/",
    "debug_level": 1
}
eof
chmod -R 777 $scriptdir/$con_file

cat >>$scriptdir/timing_backup_script.sh<<eof



space=$space
scriptdir=$scriptdir
qiniuAccessKey=$qiniuAccessKey
qiniuSecretKey=$qiniuSecretKey
backup_file_compression_password=$backup_file_compression_password
database_name=$database_name
mysql_user=$mysql_user
mysql_passwd=$mysql_passwd
info_sent_mail_to=$info_sent_mail_to
home_dir=$home_dir
mysqldump_dir=$mysqldump_dir
nginx_configuration_file=$nginx_configuration_file
local_bankup=$local_bankup
expired_days=$expired_days
con_file=$con_file
eof

chmod 777 $scriptdir/qrsync
cd $scriptdir
current_time=$(date +"%Y%m%d")
cat timing_backup_script.sh tool.sh > $current_time$domain_name.sh
rm timing_backup_script.sh
chmod -R 777 $current_time$domain_name.sh

crontab -l > /tmp/root.crontab
cat >>/tmp/root.crontab<<eof
$backup_time $scriptdir/$current_time$domain_name.sh
eof
crontab /tmp/root.crontab

echo "========================================================================="
echo " OK! Success!Congratulations to you!"
echo ""
echo "Your local backup hold time :$expired_days day"
echo "Wellcome to my blog  http://www.hhvmc.com"
echo "Your task will be in your set time, you can also directly executable file head with time of a script immediately back up now, GOOG LUCK!"
echo ""
echo ""
echo "========================================================================="
fi





