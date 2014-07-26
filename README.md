ltmh
====

In CentOS / Red Hat Debian and Ubuntu is a complete automation LTMH / LNMH / LNMP / LTMP installation script
This script is free collection of shell scripts for rapid deployment of `LTMH`/`LNMH`/`LTMP`/ `LNMP` stacks (`Linux`, `Tengine`/`Nginx`, `MySQL`/`MariaDB`/`Percona` and `PHP`/ `hhvm`) for CentOS/Redhat Debian and Ubuntu.

  Script features: 
- Constant updates 
- Source compiler installation, most source code is the latest stable version, and downloaded from the official website
- Fixes some security issues 
- You can freely choose to install database version (MySQL-5.6, MySQL-5.5, MariaDB-10.0, MariaDB-5.5, Percona-5.6, Percona-5.5)
- You can freely choose to install PHP version (php-5.5, php-5.4, php-5.3)
- You can freely choose to install hhvm version (hhvm3.1.0,hhvm3.2.0)
- You can freely choose to install Tengine or Nginx  
- According to their needs can to install ngx_pagespeed
- According to their needs can to install ZendOPcache, xcache, APCU, eAccelerator, ionCube and ZendGuardLoader (php-5.4, php-5.3) 
- According to their needs can to install Pureftpd, phpMyAdmin
- According to their needs can to install memcached, redis
- According to their needs can to optimize Nginx and Tengine with jemalloc or tcmalloc 
  
  Tengien default has been compiled ngx_lua_waf (Web Firewall), dynamically loaded modules as needed
- You can open ngx_lua_waf the necessary functions to :
  Prevent sql injection, local contain, some overflow, fuzzing test, xss, SSRF and other web attacks
  Prevent svn / backup class file leak
   ApacheBench prevent attacks like stress testing tool
  Shielding common hacking tools to scan, the scanner
   Abnormal network requests shield
   Shielding Pictures directory php execute permissions Accessories
   Upload prevent webshell
   
   
- A key to add a virtual host
- Nginx/Tengine, PHP,HHVM, Redis, phpMyAdmin upgrade script provided
- A key backup support

## How to use :
##centOS does not currently support hhvm as php Compiler interpreter

```bash
   yum -y install wget screen # for CentOS/Redhat
   #apt-get -y install wget screen # for Debian/Ubuntu 
   wget -c http://soft.hhvm.biz/ltmh.tar.gz
   #or wget -c  http://soft.hhvm.biz/ltmh.full.tar.gz# include source packages
   tar xzf ltmh.tar.gz
   cd ltmh
   chmod 777 install_lnmp.sh install_ltmh.sh 
   ##You can choose to install：Tengine+Mysql+HHVM,Nginx+Mysql+HHVM (Execute scripts ./install_ltmh.sh )
   ###You can choose to install：Nginx+Mysql+php,Tengine+Mysql+Php (Execute scripts ./install_lnmp.sh )
   ##Prevent interrupt the installation process. If the network is down, you can execute commands `screen -r ltmh` network reconnect the installation window.
   screen -S ltmh
   ./install_lnmp.sh or ./install_ltmh.sh 
```

## How to add a virtual host

```bash
   ./vhost.sh
```

## Hown to backup

```bash
   ./backup_init.sh ##Backup Initialization 
   ./backup.sh # Start backup, You can add cron jobs
   # crontab -l # Examples 
     0 1 * * * cd ~/ltmh;./backup.sh  > /dev/null 2>&1 &
```

## How to manage service
Nginx/Tengine:
```bash
   service nginx {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}
   ##tengine:/usr/local/nginx/sbin/nginx -t ,-v ,-m , -V
   ##tengine:/usr/local/nginx/sbin/dso_tool --add-module=......
```
MySQL/MariaDB/Percona:
```bash
   service mysqld {start|stop|restart|reload|force-reload|status}
```
PHP:
```bash
   service php-fpm {start|stop|force-quit|restart|reload|status}
```
HHVM:
```bash
   service hhvm {start|stop|restart|reload|status}
``` 
Pure-Ftpd:
```bash
   service pureftpd {start|stop|restart|condrestart|status}
```
Redis:
```bash
   service redis-server {start|stop|status|restart|condrestart|try-restart|reload|force-reload}
```
Memcached:
```bash
   service memcached {start|stop|status|restart|reload|force-reload}
```

## How to upgrade 
```bash
   ./up_php.sh # upgrade PHP
   ./up_web_ser.sh # upgrade Nginx/Tengine
   ./up_redis.sh # upgrade Redis 
   ./up_phpmyadmin.sh # upgrade phpMyAdmin 
```

## How to uninstall 

```bash
   ./uninstall.sh
```

   For feedback, questions, and to follow the progress of the project: <br />
   LTMH the latest source install script:http://www.hhvm.biz/forum-48-1.html<br />
   Thank you very much http://blog.linuxeye.com of yeho, learn a lot, learned a lot of things, thanks again!
