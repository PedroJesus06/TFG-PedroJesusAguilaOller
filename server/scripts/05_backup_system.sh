#!/bin/bash

echo "====================================="
echo " CARGANDO VARIABLES DE ENTORNO "
echo "====================================="

# Carga variables del archivo .env
source ../.env


echo "====================================="
echo " LIMPIANDO DESPLIEGUE ANTERIOR "
echo "====================================="

# Elimina archivos anteriores del servidor web
sudo rm -rf /var/www/html/*


echo "====================================="
echo " COPIANDO APLICACION WEB "
echo "====================================="

# Copia todos los archivos PHP al directorio web
sudo cp -r ../web/* /var/www/html/


echo "====================================="
echo " CONFIGURANDO PERMISOS "
echo "====================================="

# Cambia propietario de Apache
sudo chown -R www-data:www-data /var/www/html

# Asigna permisos seguros
sudo chmod -R 755 /var/www/html


echo "====================================="
echo " REINICIANDO APACHE "
echo "====================================="

# Reinicia Apache
sudo systemctl restart apache2


echo "====================================="
echo " VERIFICANDO APACHE "
echo "====================================="

# Comprueba estado Apache
sudo systemctl status apache2 --no-pager


echo "====================================="
echo " DESPLIEGUE WEB COMPLETADO "
echo "====================================="
