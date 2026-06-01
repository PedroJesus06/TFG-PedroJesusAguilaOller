#!/bin/bash
set -ex

# Cargamos las variables de entorno
source ../.env

# Ruta donde tienes guardado el volcado de tu base de datos
SQL_FILE="../bbdd/tienda.sql"

echo "======================================================="
echo " CREANDO BASE DE DATOS Y USUARIO DE LA APP "
echo "======================================================="

# Creamos la BBDD y el usuario leyendo del .env
mysql -e "CREATE DATABASE IF NOT EXISTS ${APP_DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${APP_DB_USER}'@'localhost' IDENTIFIED BY '${APP_DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${APP_DB_NAME}.* TO '${APP_DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "======================================================="
echo " IMPORTANDO DATOS DE PRUEBA (TIENDA) "
echo "======================================================="

# Comprobamos si el archivo SQL existe antes de importarlo
if [ -f "$SQL_FILE" ]; then
    # Inyectamos el .sql en la base de datos recién creada
    mysql "${APP_DB_NAME}" < "$SQL_FILE"
    echo "Estructura y datos de prueba importados correctamente."
else
    echo "AVISO: No se encontró el archivo $SQL_FILE."
    echo "La base de datos se ha creado, pero está vacía."
fi

echo "======================================================="
echo " CONFIGURACIÓN DE MYSQL COMPLETADA "
echo "======================================================="
