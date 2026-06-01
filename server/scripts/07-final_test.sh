#!/bin/bash
set -x
source ../.env


# Nos aseguramos de que exista la carpeta en el repositorio
mkdir -p "$LOG_DIR"

# Redirigimos la salida (pantalla + archivo log en el repositorio)
exec > >(tee -i "$LOG_FILE") 2>&1

echo "======================================="
echo " INICIANDO PRUEBAS FINALES "
echo "======================================="


echo ""
echo "[1] Comprobando servicio Apache..."

if systemctl is-active --quiet $APACHE_SERVICE
then
    echo "Apache funcionando correctamente"
else
    echo "ERROR: Apache no está activo"
fi

echo ""
echo "[2] Comprobando servicio MySQL..."

if systemctl is-active --quiet $MYSQL_SERVICE
then
    echo "MySQL funcionando correctamente"
else
    echo "ERROR: MySQL no está activo"
fi


echo ""
echo "[3] Comprobando puerto HTTP 80..."

if sudo ss -tulnp | grep ":80" > /dev/null
then
    echo "Puerto 80 abierto correctamente"
else
    echo "ERROR: Puerto 80 cerrado"
fi


echo ""
echo "[4] Comprobando puerto HTTPS 443..."

if sudo ss -tulnp | grep ":443" > /dev/null
then
    echo "Puerto 443 abierto correctamente"
else
    echo "AVISO: Puerto 443 no está abierto (Normal hasta configurar SSL)"
fi

echo ""
echo "[5] Comprobando puerto MySQL 3306..."

if sudo ss -tulnp | grep ":3306" > /dev/null
then
    echo "Puerto MySQL activo"
else
    echo "ERROR: Puerto MySQL no detectado"
fi

echo ""
echo "[6] Verificando reglas iptables..."

sudo iptables -L

echo ""
echo "[7] Verificando respuesta HTTP..."

HTTP_STATUS=$(curl -L -o /dev/null -s -w "%{http_code}\n" $WEB_URL)

if [ "$HTTP_STATUS" == "200" ]
then
    echo "Servidor web responde correctamente"
else
    echo "ERROR: El servidor web devuelve código $HTTP_STATUS"
fi

echo ""
echo "[8] Verificando archivos web..."

if [ -f /var/www/html/login.php ]
then
    echo "login.php encontrado"
else
    echo "ERROR: login.php no existe"
fi

if [ -f /var/www/html/dashboard.php ]
then
    echo "dashboard.php encontrado"
else
    echo "ERROR: dashboard.php no existe"
fi

if [ -f /var/www/html/ver_registros.php ]
then
    echo "ver_registros.php encontrado"
else
    echo "ERROR: ver_registros.php no existe"
fi

echo ""
echo "[9] Verificando bases de datos..."

mysql -u root -e "SHOW DATABASES;" | grep "database_rrhh" > /dev/null

if [ $? -eq 0 ]
then
    echo "Base de datos RRHH encontrada"
else
    echo "ERROR: database_rrhh no existe"
fi

mysql -u root -e "SHOW DATABASES;" | grep "database_tienda" > /dev/null

if [ $? -eq 0 ]
then
    echo "Base de datos TIENDA encontrada"
else
    echo "ERROR: database_tienda no existe"
fi

echo ""
echo "[10] Verificando tablas RRHH..."

mysql -u root database_rrhh -e "SHOW TABLES;"

echo ""
echo "[11] Verificando tablas TIENDA..."

mysql -u root database_tienda -e "SHOW TABLES;"

# =========================================================
# COMPROBAR SISTEMA DE BACKUPS (Destino de la base de datos)
# =========================================================
echo ""
echo "[12] Verificando backups..."

# Mantenemos la creación de la carpeta del sistema para los .sql de las bases de datos
sudo mkdir -p /opt/backups
sudo chmod 777 /opt/backups

if [ -d /opt/backups ]
then
    echo "Directorio backups encontrado en el sistema"
    ls -lh /opt/backups
else
    echo "ERROR: No existe directorio backups"
fi

# =========================================================
# COMPROBAR USO DE DISCO
# =========================================================
echo ""
echo "[13] Verificando almacenamiento..."

df -h

# =========================================================
# COMPROBAR USO DE MEMORIA
# =========================================================
echo ""
echo "[14] Verificando memoria RAM..."

free -h

echo ""
echo "======================================="
echo " PRUEBAS FINALES COMPLETADAS "
echo "======================================="