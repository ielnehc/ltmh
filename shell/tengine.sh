#!/bin/bash

Install_Tengine()
{
cd $ltmh_dir/src
. ../tools/download.sh 
. ../tools/check_os.sh 
. ../options.conf

#Check file && download
src_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.35.tar.gz && Download_src 
src_url=http://labs.frickle.com/files/ngx_cache_purge-2.1.tar.gz && Download_src 
#src_url=https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/master.zip && Download_src 
src_url=http://tengine.taobao.org/download/tengine-2.0.3.tar.gz && Download_src 
src_url=http://luajit.org/download/LuaJIT-2.0.3.tar.gz && Download_src 

tar xzf pcre-8.35.tar.gz
cd pcre-8.35
./configure
make && make install
cd ../

# LuaJIT
tar -zxvf LuaJIT-2.0.3.tar.gz
cd LuaJIT-2.0.3
mkdir /usr/local/luaJIT
make 
make install PREFIX=/usr/local/luaJIT                                                
ln -sf LuaJIT-2.0.3 /usr/local/luaJIT/bin/luajit
export LUAJIT_LIB=/usr/local/luaJIT/lib
export LUAJIT_INC=/usr/local/luaJIT/include/luajit-2.0
cd ../

#ngx_cache
tar zxvf ngx_cache_purge-2.1.tar.gz

#tengine
tar xzf tengine-2.0.3.tar.gz 
useradd -M -s /sbin/nologin www
cd tengine-2.0.3

# Modify Tengine version
#sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

# close debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

# make[1]: *** [objs/src/event/ngx_event_openssl.o] Error 1
sed -i 's@\(.*\)this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\(.*\)@#ifdef SSL_OP_MSIE_SSLV2_RSA_PADDING\n\1this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\2@' src/event/ngx_event_openssl.c
sed -i 's@\(.*\)SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\(.*\)@\1SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\2\n#endif@' src/event/ngx_event_openssl.c


./configure --prefix=$tengine_install_dir --user=www --group=www --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-http_concat_module=shared --with-http_sysguard_module=shared --with-ipv6 --with-http_spdy_module --add-module=../ngx_cache_purge-2.1 --with-http_slice_module=shared --with-http_random_index_module=shared --with-http_secure_link_module=shared --with-http_sysguard_module=shared --with-http_mp4_module=shared --with-http_lua_module=shared --with-luajit-inc=/usr/local/luaJIT/include/luajit-2.0 --with-luajit-lib=/usr/local/luaJIT/lib --with-jemalloc
make && make install
if [ -d "$tengine_install_dir" ];then
        echo -e "\033[32mTengine install successfully! \033[0m"
else
        echo -e "\033[31mTengine install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

[ -n "`cat /etc/profile | grep 'export PATH='`" -a -z "`cat /etc/profile | grep $tengine_install_dir`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$tengine_install_dir/sbin:\1@" /etc/profile
. /etc/profile

cd ../../
OS_CentOS='/bin/cp init/Nginx-init-CentOS /etc/init.d/nginx \n
chkconfig --add nginx \n
chkconfig nginx on'
OS_Debian_Ubuntu='/bin/cp init/init.d.nginx /etc/init.d/nginx \n
update-rc.d nginx defaults'
OS_command
sed -i "s@/usr/local/nginx@$tengine_install_dir@g" /etc/init.d/nginx

mv $tengine_install_dir/conf/nginx.conf{,_bk}
/bin/cp conf/nginx.conf $tengine_install_dir/conf/nginx.conf
sed -i "s@/home/wwwroot/default@$home_dir/default@" $tengine_install_dir/conf/nginx.conf
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" $tengine_install_dir/conf/nginx.conf
[ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $tengine_install_dir/conf/nginx.conf 
#web firewall
mkdir -p /data/logs/hack/
chown -R www:www /data/logs/hack/
chmod -R 755 /data/logs/hack/
/bin/cp -R tools/waf /usr/local/nginx/conf/waf
# worker_cpu_affinity
sed -i "s@^worker_processes.*@worker_processes auto;\nworker_cpu_affinity auto;\ndso {\n\tload ngx_http_lua_module.so;\n\tload ngx_http_concat_module.so;\n\tload ngx_http_sysguard_module.so;\n}@" $tengine_install_dir/conf/nginx.conf

# logrotate nginx log
cat > /etc/logrotate.d/nginx << EOF
$wwwlogs_dir/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
endscript
}
EOF

sed -i "s@^web_install_dir.*@web_install_dir=$tengine_install_dir@" options.conf
sed -i "s@/home/wwwroot@$home_dir@g" vhost.sh
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" vhost.sh
cp /usr/local/luaJIT/lib/libluajit-5.1.so.2 /usr/lib/libluajit-5.1.so.2
ldconfig
service nginx start
}
