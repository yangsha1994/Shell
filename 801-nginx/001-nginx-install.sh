#!/bin/bash 
#explain: nginx安装脚本:配置写入脚本中
#author:yangyang 

#安装
#配置root家目录
GINX_ROOT="/data/www/wwwroot"
NGINX_PORT=80
NGINX_USER=daemon
NGINX_GROUP=daemon

NGINX_VERSION="nginx-1.14.0"
NGINX_PREFIX="/xfdata/soft/nginx"

#编译添加了淘宝的监控监控模块
NGINX_COMPILE_COMMAND="./configure \
                        --user=$CONF_WWW_USER \
                        --group=$CONF_WWW_GROUP \
                        --prefix=$NGINX_PREFIX \
                        --with-http_stub_status_module \
                        --with-http_ssl_module \
                        --with-http_sub_module \
                        --with-pcre \
                        --with-file-aio \
                        --with-http_realip_module \
                        --without-http_scgi_module \
                        --without-http_fastcgi_module
                        --add-module=./nginx-1.14.0/nginx_upstream_check_module-master --add-module=./nginx-1.14.0/fastdfs-nginx-module-master/src \
                        --with-md5=/usr/lib \
                        --with-sha1=/usr/lib \
                        --with-http_gzip_static_module"


yum -y install zlib zlib-devel openssl openssl-devel pcre pcre-devel gcc gcc-c++ make

tar zxvf $NGINX_VERSION.tar.gz
cd $NGINX_VERSION
$NGINX_COMPILE_COMMAND
make -j8 && make install

#nginx配置
cat > $NGINX_PREFIX/conf/nginx.conf <<EOF

worker_processes  2;
worker_cpu_affinity 01 10;

events {
    worker_connections  10240;
}

http {

		include       mime.types;
		default_type  application/octet-stream;
IN
		log_format  main  ' $remote_addr - $remote_user [$time_local] "$request" '
						  '$status $body_bytes_sent $request_time $upstream_response_time  "$http_referer" '
						  '"http_user_agent" "$http_x_forwarded_for" '

		sendfile        on;
        server_tokens off;
		
		keepalive_timeout  65;
		proxy_buffers 16 10240k;
		proxy_buffer_size 10240k;

		gzip  on;
		gzip_min_length 1k;   
		gzip_http_version 1.1;
		gzip_buffers 4 16k;    
		gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
		gzip_comp_level 4;   
		
		
		add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Headers X-Requested-With;
        add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
		
		upstream mycluster{	
		   server 192.168.3.202:8080  weight=1;
		   server 192.168.3.203:8080  weight=1;
		   server 192.168.3.204:8080  weight=1;
		   check interval=3000 rise=2 fall=5 timeout=1000 type=http;
	   }
	   
		upstream elasticsearch{
		   server 192.168.3.202:9200;
		   server 192.168.3.203:9200;
		   server 192.168.3.204:9200;
	   }

		server {
			listen       8010;
			server_name  localhost;
			access_log  /xfdata/soft/nginx/logs/access_client.log  main;
			location /DsfireSupervision {
			   proxy_pass http://mycluster;
			   add_header backendIP $upstream_addr;
			   add_header backendCode $upstream_status;
			   proxy_connect_timeout 50s;
			   gzip_static on;
			   expires max;
			   proxy_next_upstream error timeout invalid_header http_502 http_503 http_504;
			   root   html;
			   index  index.html index.htm;
			}
			
			location /nginx_status {
				stub_status on;
				access_log off;
			}

			location /nstatus{
				check_status;
				access_log off;
			}

			error_page   500 502 503 504  /50x.html;
			location = /50x.html {
				root   html;
			}
		}

		
	   server {
			listen       83;
			server_name  localhost;
			 access_log /xfdata/soft/nginx/logs/access_ydzf.log main;
			 location /YDZFService{
				client_max_body_size 10M;

				proxy_pass http://202.91.249.27:83;

				proxy_redirect off;
				proxy_connect_timeout 50s;
				proxy_set_header Host $host:81;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 
				proxy_set_header X-Real-IP $remote_addr;

			}       
		}
	   #set onlineupgrade connect
		server {
			listen       8686;
			server_name  localhost;
			access_log /xfdata/soft/nginx/logs/access_upgrade.log main;
			 location / {
				client_max_body_size 10M;

				proxy_pass http://192.168.3.198:8686;

				proxy_redirect off;
				proxy_connect_timeout 50s;
				proxy_set_header Host $host:8686;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_set_header X-Real-IP $remote_addr;

			}
		}

	   #set elasticsearch
	   server {
			listen 9199;
			server_name localhost;
			access_log /xfdata/soft/nginx/logs/access_elasticsearch.log main;
			location / {
			  if ($request_filename ~ _shutdown) {
			 return 403;
			 break;
			 }
			  client_max_body_size 10M;
			  proxy_pass http://elasticsearch;
			  
			  proxy_redirect off;
			  proxy_connect_timeout 50s;
			  proxy_set_header Host $host:9200;
			  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			  proxy_set_header X-Real-IP $remote_addr;
			  proxy_http_version 1.1;
			  proxy_set_header Connection "Keep-Alive";
			  proxy_set_header Proxy-Connection "Keep-Alive";
			  auth_basic "Protected Elasticsearch";
			  auth_basic_user_file passwords;
			}

	   }

   }
EOF

#服务配置

 cat > /etc/init.d/nginx <<EOF
#
# chkconfig: - 69 88
# description: this script is used for nginx
# author: qzao22(qzao22@qq.com)
#
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Check if user is root
if [ \$(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!\n"
    exit 1
fi
NGINXDAEMON=$NGINX_PREFIX/sbin/nginx
PIDFILE=$NGINX_PREFIX/logs/nginx.pid
function_start()
{
    echo -en "\033[32;49;1mStarting nginx......\n"
    echo -en "\033[39;49;0m"  
    if [ -f \$PIDFILE ]; then
      printf "Nginx is runing!\n"
      exit 1
    else  
        \$NGINXDAEMON 
        printf "Nginx is the successful start!\n"
    fi
}
function_stop()
{
    echo -en "\033[32;49;1mStoping nginx......\n"
    echo -en "\033[39;49;0m" 
    if  [ -f \$PIDFILE ]; then
        kill \`cat \$PIDFILE\`
        printf "Nginx program is stoped\n"
    else  
        printf  "Nginx program is not runing!\n" 
    fi
}
function_reload()
{
    echo -en "\033[32;49;1mReload nginx......\n"
    echo -en "\033[39;49;0m"
    printf "Reload Nginx configure...\n"
    \$NGINXDAEMON -t
    kill -HUP \`cat \$PIDFILE\`
    printf "Nginx program is reloding!\n"
}
function_restart()
{
    echo -en "\033[32;49;1mRestart nginx......\n"
    echo -en "\033[39;49;0m" 
    printf "Reload Nginx configure...\n"
    \$NGINXDAEMON -t
    kill -HUP \`cat \$PIDFILE\`
    printf "Nginx program is reloding!\n"
}
function_kill()
{
    killall nginx
}
function_status()
{
    if ! ps -ef|grep 'nginx:' > /dev/null 2>&1
    then
        printf "Nginx is down!!!\n"
    else
        printf "Nginx is running now!\n"
    fi
}
if [ "\$1" = "start" ]; then
    function_start
elif [ "\$1" = "stop" ]; then
    function_stop
elif [ "\$1" = "reload" ]; then
    function_reload
elif [ "\$1" = "restart" ]; then
    function_restart
elif [ "\$1" = "kill" ]; then
    function_kill
elif [ "\$1" = "status" ]; then
    function_status
else
    echo -en "\033[32;49;1m Usage: nginx {start|stop|reload|restart|kill|status}\n"
    echo -en "\033[39;49;0m"
fi
EOF
chmod 777 /etc/init.d/nginx
echo ok
