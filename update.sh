#!/bin/bash
#
# About: Update Wordpress automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.1"

echo "Welcome on WP Update Script $version"

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
	( $wpcli_alias plugin is-installed $1 && $wpcli_alias plugin update $1 ) || $wpcli_alias plugin install $1
}

#=================================================
# ACTIVE MAINTENANCE MODE
#=================================================
$wpcli_alias maintenance-mode activate

#=================================================
# WORDPRESS UPDATE
#=================================================
$wpcli_alias core update
$wpcli_alias core update-db
$wpcli_alias core verify-checksums

#=================================================
# INSTALL PLUGINS
#=================================================
$wpcli_alias plugin is-installed wp-fail2ban-redux || $wpcli_alias plugin install wp-fail2ban-redux

#=================================================
# UPDATE PLUGINS
#=================================================
update_plugin contact-form-7
update_plugin w3-total-cache
update_plugin duplicate-post
update_plugin cookie-notice
update_plugin flow-flow
update_plugin flow-flow-social-streams
update_plugin google-analytics-dashboard-for-wp
update_plugin js_composer
update_plugin page-links-to
update_plugin revslider
update_plugin sitepress-multilingual-cms
update_plugin wp-booklet
update_plugin wordfence
update_plugin wordpress-seo
update_plugin seo-by-rank-math
update_plugin tinymce-advanced

#=================================================
# DISABLE PLUGINS
#=================================================

#$wpcli_alias plugin deactivate --all

#=================================================
# CREATE ADMIN
#=================================================

#$wpcli_alias user create adminwp adminwp@example.com --role=administrator --user_pass=mypassword

#=================================================
# SECURING FILES AND DIRECTORIES
#=================================================
chown -R $app: $final_path
chown root: $final_path/wp-config.php

#=================================================
# ACTIVE MAINTENANCE MODE
#=================================================
$wpcli_alias maintenance-mode deactivate

#=================================================
# RELOAD NGINX
#=================================================
systemctl reload nginx

#=================================================
# REMOVE WP-CLI & FILES
#=================================================
rm -f $final_path/wp-cli.phar
rm -f $final_path/readme.html
rm -f $final_path/wp-config-sample.php
rm -f $final_path/license.txt
rm -rf $final_path/wp-content/themes/twenty*
