#!/bin/bash
set -ex # 
source ../.env


echo "======================================================="
echo "   FASE 1: PURGA Y LIMPIEZA DE ENTORNOS PREVIOS        "
echo "======================================================="

echo "Deteniendo servicios de Zabbix..."
sudo systemctl stop zabbix-server zabbix-agent apache2 || true

echo "Purgando paquetes antiguos de Zabbix..."
sudo apt-get purge -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-release || true
sudo apt-get autoremove -y

echo "Eliminando bases de datos previas de Zabbix..."
sudo mysql -e "DROP DATABASE IF EXISTS ${Z_DB_NAME};" || true
sudo mysql -e "DROP USER IF EXISTS '${Z_DB_USER}'@'localhost';" || true

echo "Eliminando rastros de directorios..."
sudo rm -rf /etc/zabbix /usr/share/zabbix /var/log/zabbix /var/run/zabbix

echo "======================================================="
echo "   FASE 2: INSTALACIÓN DEL REPOSITORIO Y PACK COMPLETO "
echo "======================================================="

echo "Configurando repositorio oficial Zabbix ${ZABBIX_VER} LTS..."
wget -q "https://repo.zabbix.com/zabbix/${ZABBIX_VER}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"
sudo dpkg -i "zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"
rm "zabbix-release_${ZABBIX_VER}-1+ubuntu${OS_VER}_all.deb"

echo "Actualizando repositorios del sistema..."
sudo apt-get update -y

echo "Instalando Servidor, Frontend Web y Agente de Zabbix..."
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "======================================================="
echo "   FASE 3: CONFIGURACIÓN AUTOMÁTICA DE BASE DE DATOS   "
echo "======================================================="

echo "Creando Base de Datos y Usuario para Zabbix..."
sudo mysql -e "CREATE DATABASE ${Z_DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER '${Z_DB_USER}'@'localhost' IDENTIFIED BY '${Z_DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${Z_DB_NAME}.* TO '${Z_DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "PERMITIENDO ENRUTAMIENTO DE FUNCIONES (SOLUCIÓN ERROR 1419)..."
# Activamos temporalmente la confianza en creadores de funciones con privilegios root
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"

echo "Importando el esquema inicial de Zabbix (Esto puede tardar un minuto)..."
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u "${Z_DB_USER}" -p"${Z_DB_PASS}" "${Z_DB_NAME}"

echo " RESTAURANDO SEGURIDAD DE FUNCIONES EN MYSQL..."
# Volvemos a dejar la variable en su estado seguro original por defecto
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

echo "======================================================="
echo "   FASE 4: AJUSTES DE FICHEROS DE CONFIGURACIÓN        "
echo "======================================================="

echo "Configurando credenciales en zabbix_server.conf..."
sudo sed -i "s/^DBName=zabbix/DBName=${Z_DB_NAME}/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^DBUser=zabbix/DBUser=${Z_DB_USER}/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^# DBPassword=/DBPassword=${Z_DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "Configurando zabbix_agentd.conf con variables del .env..."
sudo sed -i "s/^Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^Hostname=Zabbix server/Hostname=${MONITORED_HOSTNAME}/" /etc/zabbix/zabbix_agentd.conf

echo "Asegurando módulos y reiniciando el ecosistema..."
sudo a2enmod status >/dev/null 2>&1
sudo systemctl daemon-reload

# Habilitar y encender todo
sudo systemctl enable zabbix-server zabbix-agent apache2
sudo systemctl restart zabbix-server zabbix-agent apache2

echo "======================================================="
echo "¡ZABBIX DESPLEGADO COMPLETA Y CORRECTAMENTE!"
echo "    Ya puedes acceder desde: http://127.0.0.1/zabbix"
echo "======================================================="