#!/bin/bash

echo "====================================="
echo " CARGANDO VARIABLES DE ENTORNO "
echo "====================================="

# Carga las variables del archivo .env
source ../.env


echo "====================================="
echo " INICIANDO SERVICIO MYSQL "
echo "====================================="

# Inicia el servicio MySQL
sudo systemctl start mysql

# Habilita MySQL al iniciar el sistema
sudo systemctl enable mysql


echo "====================================="
echo " ELIMINANDO BASES DE DATOS ANTERIORES "
echo "====================================="

# Elimina la base de datos RRHH si ya existe
sudo mysql -e "DROP DATABASE IF EXISTS ${NAME_DB_RRHH};"

# Elimina la base de datos TIENDA si ya existe
sudo mysql -e "DROP DATABASE IF EXISTS ${NAME_DB_TIENDA};"


echo "====================================="
echo " ELIMINANDO USUARIOS ANTERIORES "
echo "====================================="

# Elimina el usuario administrador anterior
sudo mysql -e "DROP USER IF EXISTS '${DB_ADMIN_USER}'@'localhost';"

# Elimina el usuario limitado anterior
sudo mysql -e "DROP USER IF EXISTS '${DB_LIMIT_USER}'@'localhost';"


echo "====================================="
echo " CREANDO BASES DE DATOS "
echo "====================================="

# Crea la base de datos RRHH
sudo mysql -e "CREATE DATABASE ${NAME_DB_RRHH};"

# Crea la base de datos TIENDA
sudo mysql -e "CREATE DATABASE ${NAME_DB_TIENDA};"


echo "====================================="
echo " CREANDO USUARIO ADMINISTRADOR "
echo "====================================="

# Crea el usuario administrador
sudo mysql -e "CREATE USER '${DB_ADMIN_USER}'@'localhost' IDENTIFIED BY '${DB_ADMIN_PASS}';"

# Asigna control total sobre ambas bases de datos
sudo mysql -e "GRANT ALL PRIVILEGES ON ${NAME_DB_RRHH}.* TO '${DB_ADMIN_USER}'@'localhost';"

sudo mysql -e "GRANT ALL PRIVILEGES ON ${NAME_DB_TIENDA}.* TO '${DB_ADMIN_USER}'@'localhost';"


echo "====================================="
echo " CREANDO USUARIO LIMITADO "
echo "====================================="

# Crea el usuario utilizado por la aplicación web
sudo mysql -e "CREATE USER '${DB_LIMIT_USER}'@'localhost' IDENTIFIED BY '${DB_LIMIT_PASS}';"

# Asigna permisos limitados sobre la base de datos RRHH
sudo mysql -e "GRANT SELECT, INSERT, UPDATE ON ${NAME_DB_RRHH}.* TO '${DB_LIMIT_USER}'@'localhost';"

# Asigna permisos limitados sobre la base de datos TIENDA
sudo mysql -e "GRANT SELECT, INSERT, UPDATE ON ${NAME_DB_TIENDA}.* TO '${DB_LIMIT_USER}'@'localhost';"


echo "====================================="
echo " ACTUALIZANDO PRIVILEGIOS MYSQL "
echo "====================================="

# Recarga los permisos de MySQL
sudo mysql -e "FLUSH PRIVILEGES;"


echo "====================================="
echo " IMPORTANDO ARCHIVOS SQL "
echo "====================================="

# Importa la base de datos RRHH
sudo mysql ${NAME_DB_RRHH} < ${DIR_BBDD}/${SQL_RRHH}

# Importa la base de datos TIENDA
sudo mysql ${NAME_DB_TIENDA} < ${DIR_BBDD}/${SQL_TIENDA}


echo "====================================="
echo " VERIFICANDO BASES DE DATOS "
echo "====================================="

# Muestra las bases de datos existentes
sudo mysql -e "SHOW DATABASES;"


echo "====================================="
echo " VERIFICANDO USUARIOS MYSQL "
echo "====================================="

# Muestra los usuarios creados
sudo mysql -e "SELECT user, host FROM mysql.user;"


echo "====================================="
echo " VERIFICANDO TABLAS RRHH "
echo "====================================="

# Muestra tablas de la base de datos RRHH
sudo mysql -e "USE ${NAME_DB_RRHH}; SHOW TABLES;"


echo "====================================="
echo " VERIFICANDO TABLAS TIENDA "
echo "====================================="

# Muestra tablas de la base de datos TIENDA
sudo mysql -e "USE ${NAME_DB_TIENDA}; SHOW TABLES;"


echo "====================================="
echo " MYSQL CONFIGURADO CORRECTAMENTE "
echo "====================================="
