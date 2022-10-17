#!/bin/bash
# Script for lemp server wordpress

#--------------------------------------------------

# Nginx: 1.14.2 MySql: 8.0  PHP 7

#--------------------------------------------------

# im using bc for make functions
# bc means basic calc
# bc used to provide the functionality of a scientific calculator
# with bc we can make a script with various arithmentic use cases and scenarios
#--------------------------------------------------

echo "* * * * * * * * * * * * * * * * * * * * * * "
echo "WELCOME TO SCRIPT FOR LEMP"

#check to make sure script can be run only by user root
bc_checkroot() {
    if (($EUID == 0)); then
        # If user is root, continue script 
        bc_init
    else
        # If user not is root, print message and automaricly exit script
        echo "***** Please run this script by user root *****  ."
        exit
    fi
}
echo "* * * * * * * * * * * * * * * * * * * * * * "
#--------------------------------------------------

# update all the packages & upgrade the system befor the proses
# make suring our packges are latest
 
bc_update() {
    echo ": Update and Upgrade"
    echo ""
    sleep 1
        apt update
        apt upgrade -y
    echo ""
    sleep 1
}
echo "* * * * * * * * * * * * * * * * * * * * * * "
#--------------------------------------------------

# this section is install LEMP stack with wordpress
# LEMP means linux enginx mysql/mariadb php.

bc_install() {

    # INSTALL NGINX
    echo ""
    echo ": Installing NGINX"
    echo ""
    sleep 1
        apt install nginx -y
        systemctl enable nginx && systemctl restart nginx
    echo ""
    sleep 1

    # INSTALL SQL DATABSE
    # WE CAN USE ANY DATABSE LIKES MYSQL MARIA OR POSTGRESQL
    
    echo ": Installing DATABASE"
    echo ""
    sleep 1
		wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb
		dpkg -i mysql-apt-config_0.8.13-1_all.deb
		dpkg-reconfigure mysql-apt-config
		apt update
		apt install mysql-server
        systemctl enable mysql && systemctl restart mysql
    echo ""
    sleep 1

    echo ": CREATING DB and USER "
    echo ""
    echo "please type your mysql passowrd 4 times"
		mysql --user=root --password -e "CREATE DATABASE wordpress /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        mysql --user=root --password -e "CREATE USER wordpress@localhost IDENTIFIED BY 'wordpress';"
        mysql --user=root --password -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
        mysql --user=root --password -e "FLUSH PRIVILEGES;"
    echo ""
    sleep 1

    # INSTALL PHP7 
    # we can also use anyother version of php
    echo ": Installing PHP 7.3"
    echo ""
    sleep 1
        apt install php7.3 php7.3-cli php7.3-common php7.3-fpm php7.3-gd php7.3-mysql -y
    echo ""
    sleep 1

    # GLOBAL CONFIGRETIONS
    
    echo ": Editing the Global Configurations"
    echo ""
    sleep 1
        sed -i 's:# Basic Settings:client_max_body_size 24m;:g' /etc/nginx/nginx.conf
        sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 12M/g' /etc/php/7.3/fpm/php.ini
        sed -i 's/post_max_size = 2M/post_max_size = 12M/g' /etc/php/7.3/fpm/php.ini
    echo ""
    sleep 1

    # MAKING THE DIRECTORIE FOR WP
    
    echo ": making wp directory"
    echo ""
    sleep 1
        mkdir /var/www/wordpress
        echo "<?php phpinfo(); ?>" >/var/www/wordpress/info.php
        chown -R www-data:www-data /var/www/wordpress
    echo ""
    sleep 1

    #VHOST CONFIG
    
    echo ": Editing the Default VHost configuration for Nginx"
    echo ""
    
    sleep 1
cat >/etc/nginx/sites-enabled/default <<"EOF"
server {
    listen 80;
    listen [::]:80;
    root /var/www/wordpress;
    index index.php index.html index.htm;
    server_name _;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ ^/wp-json/ {
        # if permalinks not enabled
        rewrite ^/wp-json/(.*?)$ /?rest_route=/$1 last;
    }
    location ~ \.php$ {
        include         fastcgi_params;
        fastcgi_pass    unix:/run/php/php7.3-fpm.sock;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index   index.php;
    }
}
EOF
    echo ""
    sleep 1

    # RESTARTING NGINX AND PHP
    # also we can restart mysql 
    
    echo ": Restarting Nginx & PHP"
    echo ""
    sleep 1
        systemctl restart nginx
        systemctl restart php7.3-fpm
    echo ""
    sleep 1

    # INSTALLING WORDPRESS LATEST VERSION
    
    echo ": Installing WordPress"
    echo ""
        wget -c http://wordpress.org/latest.tar.gz
        tar -xzvf latest.tar.gz
        rsync -av wordpress/* /var/www/wordpress/
        chown -R www-data:www-data /var/www/wordpress/
        chmod -R 755 /var/www/wordpress/
    echo ""
    sleep 1

    # FINAL DISPLAY MESSAGE
    
    sleep 1
    echo ""
        local start="You can access http://"
        local mid=`ip a | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
        local end="/ to setup your WordPress."
        echo "$start$mid$end"
        echo "**MySQL db: wordpress user: wordpress pwd: wordpress "
        echo "Thank you & good luck, ! "
    echo ""
    sleep 1

}

echo "* * * * * * * * * * * * * * * * * * * * * * "
# initializing the whole script.
bc_init() {
    bc_update
    bc_install
}

echo "* * * * * * * * * * * * * * * * * * * * * * "
# primary function.
bc_main() {
    bc_checkroot
}
bc_main
exit

