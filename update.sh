#!/bin/bash

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================
app=wordpress
final_path=/var/www/$app
wget -nv https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $final_path/wp-cli.phar
wpcli_alias="php $final_path/wp-cli.phar --allow-root --path=$final_path"
update_plugin () {
        ( $wpcli_alias plugin is-installed "$1" && $wpcli_alias plugin update "$1" ) || "$wpcli_alias"
}

#=================================================
# UPDATE PLUGINS
#=================================================
systemctl stop nginx
update_plugin contact-form-7
update_plugin w3-total-cache
update_plugin duplicate-post

#=================================================
# SECURING FILES AND DIRECTORIES
#=================================================
chown -R $app: $final_path
chown root: $final_path/wp-config.php

#=================================================
# RELOAD NGINX
#=================================================
systemctl start nginx

#=================================================
# REMOVE WP-CLI
#=================================================
rm -f $final_path/wp-cli.phar
