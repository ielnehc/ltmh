#!/bin/bash
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#############################################################################
#   LTMH/LNMH/LNMP/LTMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+       #
#   For more information please visit http://www.hhvmc.com/forum-36-1.html   #
############################################################################"

#get pwd
sed -i "s@^ltmh_dir.*@ltmh_dir=`pwd`@" ./options.conf

# get local ip address
local_IP=`./tools/get_local_ip.py`

# Definition Directory
. ./options.conf
. tools/check_os.sh
mkdir -p $home_dir/default $wwwlogs_dir $ltmh_dir/{src,conf}

#set area

	area="america"
	echo "Where are your servers located?
	asia,america,europe,oceania or africa "
	read -p "(Default area: america):" area
	if [ "$area" = "" ]; then
		area="america"
	fi
	echo "==========================="
	echo  "area=$area"

# choice upgrade OS
while :
do
	echo
        read -p "Do you want to upgrade operating system ? [y/n]: " upgrade_yn
        if [ "$upgrade_yn" != 'y' -a "$upgrade_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		[ -e init/init_*.ed -a "$upgrade_yn" == 'y' ] && { echo -e "\033[31mYour system is already upgraded! \033[0m" ; upgrade_yn=n ; }
                break
        fi
done

# check Web server
while :
do
        echo
        read -p "Do you want to install Web server? [y/n]: " Web_yn
        if [ "$Web_yn" != 'y' -a "$Web_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$Web_yn" == 'y' ];then
                        [ -d "$web_install_dir" ] && { echo -e "\033[31mThe web service already installed! \033[0m" ; Web_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select Nginx server:'
                                echo -e "\t\033[32m1\033[0m. Install Nginx"
                                echo -e "\t\033[32m2\033[0m. Install Tengine"
                                echo -e "\t\033[32m3\033[0m. Do not install"
                                read -p "Please input a number:(Default 1 press Enter) " Nginx_version
                                [ -z "$Nginx_version" ] && Nginx_version=1
                                if [ $Nginx_version != 1 -a $Nginx_version != 2 -a $Nginx_version != 3 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
                                else
                                if [ $Nginx_version = 1 -o $Nginx_version = 2 ];then
                                        break;
                                fi

                                break
                                fi
                        done
                fi
                break
        fi
done


# choice database
while :
do
        echo
        read -p "Do you want to install Database? [y/n]: " DB_yn
        if [ "$DB_yn" != 'y' -a "$DB_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$DB_yn" == 'y' ];then
                        [ -d "$db_install_dir" ] && { echo -e "\033[31mThe database already installed! \033[0m" ; DB_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select a version of the Database:'
                                echo -e "\t\033[32m1\033[0m. Install MySQL-5.6"
                                echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
                                echo -e "\t\033[32m3\033[0m. Install MariaDB-10.0"
                                echo -e "\t\033[32m4\033[0m. Install MariaDB-5.5"
                                read -p "Please input a number:(Default 1 press Enter) " DB_version
                                [ -z "$DB_version" ] && DB_version=1
                                if [ $DB_version != 1 -a $DB_version != 2 -a $DB_version != 3 -a $DB_version != 4 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3,4 \033[0m"
                                else
                                        while :
                                        do
                                                read -p "Please input the root password of database: " dbrootpwd
                                                (( ${#dbrootpwd} >= 5 )) && sed -i "s@^dbrootpwd.*@dbrootpwd=$dbrootpwd@" ./options.conf && break || echo -e "\033[31mdatabase root password least 5 characters! \033[0m"
                                        done
                                        break
                                fi
                        done
                fi
                break
        fi
done

# check phpMyAdmin
while :
do
        echo
        read -p "Do you want to install phpMyAdmin? [y/n]: " phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' -a "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		if [ "$phpMyAdmin_yn" == 'y' ];then
		        [ -d "$home_dir/default/phpmyadmin" ] && echo -e "\033[31mThe phpMyAdmin already installed! \033[0m" && phpMyAdmin_yn=n && break
		fi
                break
        fi
done



# check hhvm
 while :
 do
	 echo
         read -p "Do you want to install hhvm? [y/n]: " hhvm_yn
         if [ "$hhvm_yn" != 'y' -a "$hhvm_yn" != 'n' ];then
                 echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
         else
		 if [ "$hhvm_yn" == 'y' ] && [ `getconf LONG_BIT` = 64 ];then
		 echo "hhvm will install";
		 else 
			  { echo -e "\033[31mSorry, do not support the 32 bit system, will exit! \033[0m" ; hhvm_yn=n ; exit ;}
		 fi
                 break
         fi
 done

chmod +x shell/*.sh init/* *.sh

# init
if [ "$OS" == 'CentOS' ];then
	. init/init_CentOS_hhvm.sh 2>&1 | tee $ltmh_dir/install.log
	[ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ];then
	. init/init_Debian_hhvm.sh 2>&1 | tee $ltmh_dir/install.log
elif [ "$OS" == 'Ubuntu' ];then
	. init/init_Ubuntu_hhvm.sh 2>&1 | tee $ltmh_dir/install.log
fi

# Optimization compiled code using safe, sane CFLAGS and CXXFLAGS
if [ "$gcc_sane_yn" == 'y' ];then
        if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
                export CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        elif [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
                export CHOST="i686-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        fi
fi

# jemalloc 
	. shell/jemalloc.sh
	Install_jemalloc | tee -a $ltmh_dir/install.log

# Database
if [ "$DB_version" == '1' ];then
    . shell/mysql-5.6.sh 
    Install_MySQL-5-6 2>&1 | tee -a $ltmh_dir/install.log 
elif [ "$DB_version" == '2' ];then
        . shell/mysql-5.5.sh
        Install_MySQL-5-5 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$DB_version" == '3' ];then
    . shell/mariadb-10.0.sh
    Install_MariaDB-10-0 2>&1 | tee -a $ltmh_dir/install.log 
elif [ "$DB_version" == '4' ];then
    . shell/mariadb-5.5.sh
    Install_MariaDB-5-5 2>&1 | tee -a $ltmh_dir/install.log 
fi

# Web server
if [ "$Nginx_version" == '1' ];then
        . shell/nginx_hhvm.sh
        Install_Nginx 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$Nginx_version" == '2' ] && [ "$OS" == 'CentOS' ];then
	    . shell/tengine_hhvm_centos.sh
        Install_Tengine 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$Nginx_version" == '2' ] && [ "$OS" == 'Debian' ];then
        . shell/tengine_hhvm.sh
        Install_Tengine 2>&1 | tee -a $ltmh_dir/install.log
elif [ "$Nginx_version" == '2' ] && [ "$OS" == 'Ubuntu' ];then
        . shell/tengine_hhvm.sh
        Install_Tengine 2>&1 | tee -a $ltmh_dir/install.log
fi

# ngx_pagespeed
# if [ "$ngx_pagespeed_yn" == 'y' ];then
# 	. shell/ngx_pagespeed.sh
# 	Install_ngx_pagespeed 2>&1 | tee -a $ltmh_dir/install.log
# fi

# hhvm
if [ "$OS" == 'CentOS' ] && [ "$hhvm_yn" == 'y' ] && [ `getconf LONG_BIT` == 64 ];then
	. shell/hhvm_CentOS.sh
	Install_hhvm | tee -a $ltmh_dir/install.log
	[ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ] && [ "$hhvm_yn" == 'y' ] && [ `getconf LONG_BIT` == 64 ];then
	. shell/hhvm-3.3_Debian.sh
	Install_hhvm | tee -a $ltmh_dir/install.log
elif [ "$OS" == 'Ubuntu' ] && [ "$hhvm_yn" == 'y' ] && [ `getconf LONG_BIT` == 64 ];then
	. shell/hhvm_Ubuntu.sh
	Install_hhvm | tee -a $ltmh_dir/install.log
fi

# phpMyAdmin
if [ "$phpMyAdmin_yn" == 'y' ];then
	. shell/phpmyadmin.sh
	Install_phpMyAdmin 2>&1 | tee -a $ltmh_dir/install.log
fi


# get db_install_dir and web_install_dir
. ./options.conf

# index example
if [ ! -e "$home_dir/default/index.html" -a "$Web_yn" == 'y' ];then
	. tools/init.sh
	INIT 2>&1 | tee -a $ltmh_dir/install.log 
fi

echo "####################Congratulations########################"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' ] && echo -e "\n`printf "%-32s" "Nginx/Tengine install dir":`\033[32m$web_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Database install dir:"`\033[32m$db_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database data dir:"`\033[32m$db_data_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database user:"`\033[32mroot\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database password:"`\033[32m${dbrootpwd}\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "\n`printf "%-32s" "phpMyAdmin dir:"`\033[32m$home_dir/default/phpMyAdmin\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "`printf "%-32s" "phpMyAdmin Control Panel url:"`\033[32mhttp://$local_IP/phpmyadmin\033[0m"
[ "$hhvm_yn" == 'y' ] && [ `getconf LONG_BIT` == 64 ] && echo -e "\n`printf "%-32s" "hhvm install dir:"`\033[32m$hhvm_install_dir\033[0m"
[ "$Web_yn" == 'y' ] && echo -e "\n`printf "%-32s" "index url:"`\033[32mhttp://$local_IP/\033[0m"
while :
do
        echo
        echo -e "\033[31mPlease restart the server and see if the services start up fine.\033[0m"
        read -p "Do you want to restart OS ? [y/n]: " restart_yn
        if [ "$restart_yn" != 'y' -a "$restart_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done
[ "$restart_yn" == 'y' ] && reboot
