#!/usr/bin/env bash

Green="\033[32m"
Font="\033[0m"
Blue="\033[33m"
Red="\033[31m"

rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}

checkos(){
    if [[ -f /etc/redhat-release ]];then
        OS=CentOS
    elif cat /etc/issue | grep -q -E -i "debian";then
        OS=Debian
    elif cat /etc/issue | grep -q -E -i "ubuntu";then
        OS=Ubuntu
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat";then
        OS=CentOS
    elif cat /proc/version | grep -q -E -i "debian";then
        OS=Debian
    elif cat /proc/version | grep -q -E -i "ubuntu";then
        OS=Ubuntu
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat";then
        OS=CentOS
    else
        echo "Not supported OS, Please reinstall OS and try again."
        exit 1
    fi
}

disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

install(){
    echo -e "${Green}即将安装...${Font}"
    if [ "${OS}" == 'CentOS' ];then
        yum install epel-release -y
        yum install -y wget
        wget -N -P /usr/sbin/ https://file.reimucloud.com/bin/tengine/CentOS/nginx
        chmod +x /usr/sbin/nginx
        wget -N -P /lib/systemd/system/ https://file.reimucloud.com/bin/tengine/nginx.service
		mkdir /usr/local/nginx
		mkdir /usr/local/nginx/logs
		mkdir /etc/nginx
		mkdir /etc/nginx/conf.d
		mkdir /etc/nginx/tls
		wget -N -P /etc/nginx -O nginx https://github.com/HynoR/nginx-mini/releases/download/v0.01/nginx-centos
		wget -N -P /etc/nginx https://file.reimucloud.com/bin/tengine/CentOS/mime.types
        wget -N -P /etc/nginx/conf.d https://file.reimucloud.com/bin/nginx_proxy/ws
        wget -N -P /etc/nginx/tls https://file.reimucloud.com/bin/nginx_proxy/tls-cli
        wget -N -P /etc/nginx/tls https://file.reimucloud.com/bin/nginx_proxy/tls-server
        wget -N -P /etc/nginx/conf.d https://file.reimucloud.com/bin/tengine/readme
		mkdir /etc/nginx/modules
		wget -N -P   /etc/nginx/modules -O ngx_stream_module.so https://github.com/HynoR/nginx-mini/releases/download/v0.01/ngx_stream_module_c.so
        systemctl start nginx
        systemctl enable nginx
        echo -e "${Green}done!${Font}"
    else
        apt-get -y update
        apt-get install -y wget
        wget -N -P /usr/sbin/ https://github.com/HynoR/nginx-mini/releases/download/v0.01/nginx-deb
        chmod +x /usr/sbin/nginx
        wget -N -P /lib/systemd/system/ https://file.reimucloud.com/bin/tengine/nginx.service
		mkdir /usr/local/nginx
		mkdir /usr/local/nginx/logs
		mkdir /etc/nginx
		mkdir /etc/nginx/conf.d
		mkdir /etc/nginx/tls
		wget -N -P  /etc/nginx -O nginx https://file.reimucloud.com/bin/tengine/nginx.conf
		wget -N -P /etc/nginx https://file.reimucloud.com/bin/tengine/CentOS/mime.types
        wget -N -P /etc/nginx/conf.d https://file.reimucloud.com/bin/nginx_proxy/ws
        wget -N -P /etc/nginx/tls https://file.reimucloud.com/bin/nginx_proxy/tls-cli
        wget -N -P /etc/nginx/tls https://file.reimucloud.com/bin/nginx_proxy/tls-server
        wget -N -P /etc/nginx/conf.d https://file.reimucloud.com/bin/tengine/readme
		mkdir /etc/nginx/modules
		wget -N -P   /etc/nginx/modules -O ngx_stream_module.so https://github.com/HynoR/nginx-mini/releases/download/v0.01/ngx_stream_module_d.so
        systemctl start nginx
        systemctl enable nginx
        echo -e "${Green}done!${Font}"
    fi
}

main(){
    rootness
	useradd -s /sbin/nologin -M www-data
    checkos
    disable_selinux
    systemctl stop nginx
    clear
    install
    rm tengine_relay.sh
    echo -e "${Red}使用前请先阅读/etc/nginx/conf.d/readme${Font}"
    }

main
