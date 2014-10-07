#!/bin/bash
Install_phpMyAdmin()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../options.conf 

src_url=https://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.2.9.1/phpMyAdmin-4.2.9.1-all-languages.tar.gz && Download_src
tar xzf phpMyAdmin-4.2.9.1-all-languages.tar.gz
/bin/mv phpMyAdmin-4.2.9.1-all-languages $home_dir/default/phpmyadmin
/bin/cp $home_dir/default/phpmyadmin/{config.sample.inc.php,config.inc.php}
mkdir $home_dir/default/phpmyadmin/{upload,save}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $home_dir/default/phpmyadmin/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $home_dir/default/phpmyadmin/config.inc.php
chown -R www.www $home_dir/default/phpmyadmin
cd ..
}
