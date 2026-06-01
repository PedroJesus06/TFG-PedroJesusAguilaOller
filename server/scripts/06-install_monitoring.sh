#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

source ../.env

# Purgamos por completo para asegurar instalación limpia
sudo apt-get purge -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-release || true
sudo apt-get autoremove -y

# Eliminamos bases de datos e inicios previos usando las variables del .env
sudo mysql -e "DROP DATABASE IF EXISTS ${Z_DB_NAME};" || true
sudo mysql -e "DROP USER IF EXISTS '${Z_DB_USER}'@'localhost';" || true
sudo mysql -e "DROP USER IF EXISTS 'zbx_monitor'@'localhost';" || true
sudo rm -rf /etc/zabbix /usr/share/zabbix /var/log/zabbix /var/run/zabbix /var/lib/zabbix/.my.cnf

echo "======================================================="
echo "           INSTALACIÓN DEL REPOSITORIO Y PACKAGES      "
echo "======================================================="
# Usamos las versiones configuradas en tu .env (7.0 y 24.04)
wget -q "https://repo.zabbix.com/zabbix/${ZABBIX_VER}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"
sudo dpkg -i "zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"
rm "zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"

sudo apt-get update -y
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "======================================================="
echo "           PREPARACIÓN DE LA BASE DE DATOS (MYSQL)     "
echo "======================================================="
# Creamos la base de datos y los usuarios leyendo directamente del .env
sudo mysql -e "CREATE DATABASE ${Z_DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER '${Z_DB_USER}'@'localhost' IDENTIFIED BY '${Z_DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${Z_DB_NAME}.* TO '${Z_DB_USER}'@'localhost';"

# Dejamos listo el usuario interno para que el Agente pueda leer las gráficas de MySQL
sudo mysql -e "CREATE USER 'zbx_monitor'@'localhost' IDENTIFIED BY '${Z_DB_PASS}';"
sudo mysql -e "GRANT REPLICATION CLIENT, PROCESS, SHOW DATABASES, SHOW VIEW ON *.* TO 'zbx_monitor'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Evitamos el error 1419 de AWS de forma temporal
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Importamos el esquema (con la contraseña pegada al -p para evitar fallos)
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u"${Z_DB_USER}" -p"${Z_DB_PASS}" "${Z_DB_NAME}"

# Devolvemos MySQL a su estado seguro predeterminado
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

echo "======================================================="
echo "   CONFIGURACIÓN DEL SERVIDOR Y DEL AGENTE            "
echo "======================================================="

# 4.1 Vinculamos el demonio Zabbix Server con la Base de Datos
sudo sed -i "s/^DBName=zabbix/DBName=${Z_DB_NAME}/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^DBUser=zabbix/DBUser=${Z_DB_USER}/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^# DBPassword=/DBPassword=${Z_DB_PASS}/" /etc/zabbix/zabbix_server.conf

# 4.2 Configuración básica del Agente de monitorización
sudo sed -i "s/^Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^Hostname=Zabbix server/Hostname=${MONITORED_HOSTNAME}/" /etc/zabbix/zabbix_agentd.conf

# Dejamos las credenciales preparadas para el agente usando los datos del .env
sudo mkdir -p /var/lib/zabbix
sudo tee /var/lib/zabbix/.my.cnf > /dev/null <<EOF
[client]
user=zbx_monitor
password=${Z_DB_PASS}
EOF
sudo chown zabbix:zabbix /var/lib/zabbix/.my.cnf
sudo chmod 600 /var/lib/zabbix/.my.cnf

#Descargamos la plantilla directamente desde el Git oficial de Zabbix 7.0
sudo wget -q -O /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf https://raw.githubusercontent.com/zabbix/zabbix/release/7.0/templates/db/mysql_agent/userparameter_mysql.conf

echo "======================================================="
echo "    ARRANQUE DE SERVICIOS                       "
echo "======================================================="
sudo a2enmod status >/dev/null 2>&1
sudo systemctl daemon-reload

sudo systemctl enable zabbix-server zabbix-agent apache2
sudo systemctl restart zabbix-server zabbix-agent apache2

echo "======================================================="
echo "    CONFIGURACIÓN INICIAL TERMINADA"
echo "    Entra en http://100.51.26.144/zabbix para iniciar el asistente web manual."
echo "======================================================="