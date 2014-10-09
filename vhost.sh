#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
###########################################################################################
#        LMTH/LNTH/LNMP/LTMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+                #
# For more information please visit http://www.hhvmc.com/thread-17-1-1.html               #
###########################################################################################
"
. ./options.conf

Input_domain()
{
while :
do
	echo
	read -p "Please input domain(example: www.hhvmc.com hhvmc.com): " domain
	if [ -z "`echo $domain | grep '.*\..*'`" ]; then
		echo -e "\033[31minput error! \033[0m"
	else
		break
	fi
done

if [ -e "$web_install_dir/conf/vhost/$domain.conf" -o -e "$apache_install_dir/conf/vhost/$domain.conf" ]; then
	[ -e "$web_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Nginx/Tengine already exist!\nYou can delete \033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
	[ -e "$apache_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Apache already exist!\nYou can delete \033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
	exit 1
else
	echo "domain=$domain"
fi

while :
do
	echo ''
        read -p "Do you want to add more domain name? [y/n]: " moredomainame_yn 
        if [ "$moredomainame_yn" != 'y' ] && [ "$moredomainame_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done

if [ "$moredomainame_yn" == 'y' ]; then
        while :
        do
                echo
                read -p "Type domainname,example(blog.hhvmc.com bbs.hhvmc.com): " moredomain
                if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
                        echo -e "\033[31minput error\033[0m"
                else
			[ "$moredomain" == "$domain" ] && echo -e "\033[31mDomain name already exists! \033[0m" && continue
                        echo domain list="$moredomain"
                        moredomainame=" $moredomain"
                        break
                fi
        done
        Domain_alias=ServerAlias$moredomainame
fi

echo
echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain): " vhostdir
if [ -z "$vhostdir" ]; then
        vhostdir="/home/wwwroot/$domain"
        echo -e "Virtual Host Directory=\033[32m$vhostdir\033[0m"
fi
echo
echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R www.www $vhostdir
}

Nginx_anti_hotlinking()
{
while :
do
	echo ''
        read -p "Do you want to add hotlink protection? [y/n]: " anti_hotlinking_yn 
        if [ "$anti_hotlinking_yn" != 'y' ] && [ "$anti_hotlinking_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ -n "`echo $domain | grep '.*\..*\..*'`" ];then
        domain_allow="*.${domain#*.} $domain"
else
        domain_allow="*.$domain $domain"
fi

if [ "$anti_hotlinking_yn" == 'y' ];then 
	if [ "$moredomainame_yn" == 'y' ]; then
		domain_allow_all=$domain_allow$moredomainame
	else
		domain_allow_all=$domain_allow
	fi
	anti_hotlinking=$(echo -e "location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv)$ {\n\tvalid_referers none blocked $domain_allow_all;\n\tif (\$invalid_referer) {\n\t\t#rewrite ^/ http://www.hhvmc.com/403.html;\n\t\treturn 403;\n\t\t}\n\t}")
else
	anti_hotlinking=
fi
}

Nginx_rewrite()
{
while :
do
	echo ''
        read -p "Allow Rewrite rule? [y/n]: " rewrite_yn
        if [ "$rewrite_yn" != 'y' ] && [ "$rewrite_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$rewrite_yn" == 'n' ];then
	rewrite="none"
	touch "$web_install_dir/conf/$rewrite.conf"
else
	echo ''
	echo "Please input the rewrite of programme :"
	echo -e "\033[32mwordpress\033[0m,\033[32mdiscuz\033[0m,\033[32mphpwind\033[0m,\033[32mtypecho\033[0m,\033[32mecshop\033[0m,\033[32mdrupal\033[0m rewrite was exist."
	read -p "(Default rewrite: other):" rewrite
	if [ "$rewrite" == "" ]; then
		rewrite="other"
	fi
	echo -e "You choose rewrite=\033[32m$rewrite\033[0m" 
	if [ -s "conf/$rewrite.conf" ];then
		/bin/cp conf/$rewrite.conf $web_install_dir/conf/$rewrite.conf
	else
		touch "$web_install_dir/conf/$rewrite.conf"
	fi
fi
}

Nginx_log()
{
while :
do
	echo ''
        read -p "Allow Nginx/Tengine access_log? [y/n]: " access_yn 
        if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$access_yn" == 'n' ]; then
	N_log="access_log off;"
else
	N_log="access_log /home/wwwlogs/${domain}_nginx.log combined;"
	echo -e "You access log file=\033[32m/home/wwwlogs/${domain}_nginx.log\033[0m"
fi
}

Create_nginx_conf()
{
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.jsp index.php;
include $rewrite.conf;
root $vhostdir;
#error_page 404 /404.html;
if ( \$query_string ~* ".*[\;'\<\>].*" ){
	return 404;
	}
$anti_hotlinking
location ~ .*\.(php|php5)?$  {
	#fastcgi_pass remote_php_ip:9000;
	fastcgi_pass unix:/dev/shm/php-cgi.sock;
	fastcgi_index index.php;
	include fastcgi.conf;
	}

location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
	expires 30d;
	}

location ~ .*\.(js|css)?$ {
	expires 7d;
	}
}
EOF

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
	echo "Restart Nginx......"
	$web_install_dir/sbin/nginx -s reload
else
	rm -rf $web_install_dir/conf/vhost/$domain.conf
	echo -e "Create virtualhost ... \033[31m[FAILED]\033[0m"
	exit 1
fi

printf "
###########################################################################################
#        LMTH/LNTH/LNMP/LTMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+                #
# For more information please visit http://www.hhvmc.com/thread-17-1-1.html               #
###########################################################################################
"
echo -e "`printf "%-32s" "Your domain:"`\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Virtualhost conf:"`\033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of:"`\033[32m$vhostdir\033[0m"
[ "$rewrite_yn" == 'y' ] && echo -e "`printf "%-32s" "Rewrite rule:"`\033[32m$rewrite\033[0m" 
}

    Input_domain
    Nginx_anti_hotlinking
    Nginx_rewrite
    Nginx_log
    Create_nginx_conf

