#!/bin/bash
qiniu_space=http://$space.qiniudn.com
backup_database_name=Database_$(date +"%Y%m%d").tar.gz
Web_backup_name=Website_$(date +"%Y%m%d").tar.gz
configuration_file=Nginx_conf_$(date +"%Y%m%d").tar.gz
Compressed_file_name=Data_$(date +"%Y%m%d").zip

daybc=day
old_backup_data_file_name=Data_$(date -d -$expired_days$daybc +"%Y%m%d").zip

if [ ! -f $local_bankup/$old_backup_data_file_name ]; then 
rm $local_bankup/$old_backup_data_file_name
fi 

cd $local_bankup
$mysqldump_dir -u$mysql_user -p$mysql_passwd $database_name>backup.sql

cd $local_bankup
tar zcf $local_bankup/$backup_database_name backup.sql
rm $local_bankup/backup.sql

cd $home_dir
tar zcf $local_bankup/$Web_backup_name *
 
cd $nginx_configuration_file
tar zcf $local_bankup/$configuration_file *
 
cd $local_bankup
zip -q -r -P $backup_file_compression_password $Compressed_file_name $Web_backup_name $backup_database_name $configuration_file

rm $Web_backup_name $backup_database_name $configuration_file

SJS=$(cat /proc/sys/kernel/random/uuid)

mkdir -p $local_bankup/bf_tmp/$SJS
cp $Compressed_file_name $local_bankup/bf_tmp/$SJS/$Compressed_file_name

$scriptdir/qrsync -skipsym $scriptdir/$con_file

echo "The site data backup, the backup download address：$qiniu_space/$SJS/$Compressed_file_name" >> backup_ok.txt

rm backup_ok.txt
cd $local_bankup
rm -rf $local_bankup/bf_tmp