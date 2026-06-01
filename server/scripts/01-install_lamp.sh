#!/bin/bash
set -ex

echo "====================================="
echo " LIMPIEZA PREVIA DEL SISTEMA "
echo "====================================="

# Paramos los servicios (si fallan porque ya están muertos, no pasa nada gracias al || true)
systemctl stop apache2 || true
systemctl stop mysql || true

# Purgamos los paquetes explícitamente
apt-get purge -y apache2* mysql-server mysql-client mysql-common php* || true
apt-get autoremove -y
apt-get autoclean -y

# Borrar los directorios residuales que confunden a dpkg
rm -rf /etc/apache2
rm -rf /etc/mysql
rm -rf /var/lib/mysql
rm -rf /var/www/html/*

echo "====================================="
echo " ACTUALIZANDO SISTEMA "
echo "====================================="

apt-get update -y

echo "====================================="
echo " INSTALANDO PAQUETE LAMP Y MÓDULOS "
echo "====================================="

# Instalamos explícitamente los paquetes base y los módulos extra de una sola tacada
apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-mbstring unzip curl net-tools

echo "====================================="
echo " HABILITANDO SERVICIOS "
echo "====================================="

systemctl enable apache2
systemctl start apache2

systemctl enable mysql
systemctl start mysql

echo "====================================="
echo " VERIFICANDO SERVICIOS "
echo "====================================="

# Usamos || true por si fallan al mostrar el status en sistemas muy restringidos
systemctl status apache2 --no-pager || true
systemctl status mysql --no-pager || true

echo "====================================="
echo " INSTALACIÓN COMPLETADA "
echo "====================================="