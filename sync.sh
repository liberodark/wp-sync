#!/bin/bash
#
# About: Sync repo automatically
# Author: liberodark
# Thanks : 
# License: GNU GPLv3

version="0.0.1"

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

distribution=$(cat /etc/*release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
#user=liberodark
#project=myproject

sync_rhel(){
      mkdir -p /var/www/$project/
      cd /var/www/$project/
      git pull
      chown -R nginx: /var/www/$project/
      find /var/www/wp-syms/* -type d -exec chmod 755 $(basename '{}') \;
      find /var/www/wp-syms/* -type f -exec chmod 644 $(basename '{}') \;
      chmod 0644 .htaccess
      chmod 0640 wp-config.php
      systemctl reload httpd
      }  
      
sync_deb(){
      mkdir -p /var/www/$project/
      cd /var/www/$project/
      git pull
      chown -R nginx: /var/www/$project/
      find /var/www/wp-syms/* -type d -exec chmod 755 $(basename '{}') \;
      find /var/www/wp-syms/* -type f -exec chmod 644 $(basename '{}') \;
      chmod 0644 .htaccess
      chmod 0640 wp-config.php
      systemctl reload apache2
      }
      
check_git(){
echo "Install Git Server ($distribution)"

  # Check OS & git

  if ! command -v git &> /dev/null; then

    if [[ "$distribution" = CentOS || "$distribution" = CentOS || "$distribution" = Red\ Hat || "$distribution" = Fedora || "$distribution" = Suse || "$distribution" = Oracle ]]; then
      yum install -y git &> /dev/null

      compile_nrpe_ssl || exit
    
    elif [[ "$distribution" = Debian || "$distribution" = Ubuntu || "$distribution" = Deepin ]]; then
      apt-get update &> /dev/null
      apt-get install -y git --force-yes &> /dev/null
    
      compile_nrpe_ssl || exit
      
    elif [[ "$distribution" = Clear ]]; then
      swupd bundle-add git &> /dev/null
    
      compile_nrpe_ssl || exit
      
    elif [[ "$distribution" = Manjaro || "$distribution" = Arch\ Linux ]]; then
      pacman -S git --noconfirm &> /dev/null
    
      compile_nrpe_ssl || exit

    fi
fi
}

#=================================================
# ASK
#=================================================

echo "What is your git user ?"
read -r user

echo "What is your git project ?"
read -r project

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
sync
