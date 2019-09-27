#!/bin/bash
#
# About: Sync repo automatically
# Author: liberodark
# Thanks : 
# License: GNU GPLv3

version="0.1.3"

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

distribution=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
user=liberodark
project=myproject
http_server=apache
chown_user=apache

sync_rhel(){
      mkdir -p /var/www/${project}/
      cd /var/www/${project}/ || exit
      git pull
      chown -R $chown_user: /var/www/${project}/
      find /var/www/${project}/* -type d -exec chmod 755 $(basename '{}') \;
      find /var/www/${project}/* -type f -exec chmod 644 $(basename '{}') \;
      chmod 0644 .htaccess
      chmod 0640 wp-config.php
      systemctl reload httpd && systemctl reload nginx &> /dev/null
      }  
      
sync_deb(){
      mkdir -p /var/www/${project}/
      cd /var/www/${project}/ || exit
      git pull
      chown -R $chown_user: /var/www/${project}/
      find /var/www/${project}/* -type d -exec chmod 755 $(basename '{}') \;
      find /var/www/${project}/* -type f -exec chmod 644 $(basename '{}') \;
      chmod 0644 .htaccess
      chmod 0640 wp-config.php
      systemctl reload apache2 && systemctl reload nginx &> /dev/null
      }
      
check_git(){
echo "Install Git Server ($distribution)"

  # Check OS & git

  if ! command -v git &> /dev/null; then

    if [[ "$distribution" = CentOS || "$distribution" = CentOS || "$distribution" = Red\ Hat || "$distribution" = Fedora || "$distribution" = Suse || "$distribution" = Oracle ]]; then
      yum install -y git &> /dev/null
    
    elif [[ "$distribution" = Debian || "$distribution" = Ubuntu || "$distribution" = Deepin ]]; then
      apt-get update &> /dev/null
      apt-get install -y git --force-yes &> /dev/null
      
    elif [[ "$distribution" = Clear ]]; then
      swupd bundle-add git &> /dev/null
      
    elif [[ "$distribution" = Manjaro || "$distribution" = Arch\ Linux ]]; then
      pacman -S git --noconfirm &> /dev/null

    fi
fi
}

sync_wp(){
echo "Sync WP Server ($distribution)"

  # Check OS & sync

 if [[ "$distribution" = CentOS || "$distribution" = CentOS || "$distribution" = Red\ Hat || "$distribution" = Fedora || "$distribution" = Suse || "$distribution" = Oracle ]]; then
      sync_rhel || exit
      
    elif [[ "$distribution" = Debian || "$distribution" = Ubuntu || "$distribution" = Deepin ]]; then
      sync_deb || exit
      
    elif [[ "$distribution" = Clear ]]; then
      sync_deb || exit
      
    elif [[ "$distribution" = Manjaro || "$distribution" = Arch\ Linux ]]; then
      sync_deb || exit
fi
}

#=================================================
# ASK
#=================================================

#echo "What is your git user ?"
#read -r user

#echo "What is your git project ?"
#read -r project

#==============================================
# INSTALL Git
#==============================================

#git config credential.helper store
#https://github.com/${user}/${project}
#https://${user}@github.com/${user}/${project}.git

#==============================================
# SYNC
#==============================================

check_git
sync_wp
