#!/bin/bash

echo "====================================="
echo " LIMPIEZA PREVIA DEL SISTEMA "
echo "====================================="

sudo systemctl stop apache2 2>/dev/null
sudo systemctl stop mysql 2>/dev/null

sudo apt purge apache2* -y
sudo apt purge mysql-server mysql-client mysql-common -y
sudo apt purge php* -y

sudo apt autoremove -y
sudo apt autoclean -y

sudo rm -rf /etc/mysql
sudo rm -rf /var/lib/mysql
sudo rm -rf /var/www/html/*

echo "====================================="
echo " ACTUALIZANDO SISTEMA "
echo "====================================="

sudo apt update && sudo apt upgrade -y

echo "====================================="
echo " INSTALANDO STACK LAMP "
echo "====================================="

sudo apt install lamp-server^ -y

echo "====================================="
echo " INSTALANDO MODULOS EXTRA "
echo "====================================="

sudo apt install php-mysql php-cli php-curl php-mbstring unzip curl net-tools -y

echo "====================================="
echo " HABILITANDO SERVICIOS "
echo "====================================="

sudo systemctl enable apache2
sudo systemctl start apache2

sudo systemctl enable mysql
sudo systemctl start mysql

echo "====================================="
echo " VERIFICANDO SERVICIOS "
echo "====================================="

systemctl status apache2 --no-pager
systemctl status mysql --no-pager

echo "====================================="
echo " INSTALACION COMPLETADA "
echo "====================================="
