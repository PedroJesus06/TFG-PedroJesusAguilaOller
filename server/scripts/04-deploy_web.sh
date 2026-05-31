#!/bin/bash

echo "====================================="
echo " CARGANDO VARIABLES DE ENTORNO "
echo "====================================="

# Carga variables del archivo .env
source ../.env


echo "====================================="
echo " LIMPIANDO DESPLIEGUE ANTERIOR "
echo "====================================="

# Elimina despliegues anteriores
sudo rm -rf /var/www/html/*


echo "====================================="
echo " COPIANDO APLICACION WEB "
echo "====================================="

# Copia todos los archivos web
sudo cp -r ../web/* /var/www/html/


echo "====================================="
echo " GENERANDO conexion.php "
echo "====================================="

echo "====================================="
echo " GENERANDO conexion.php "
echo "====================================="

# Genera automáticamente el archivo conexion.php dinámico por sesión (Versión Blindada)
sudo tee /var/www/html/conexion.php > /dev/null <<EOF
<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

\$servername = "localhost";

// Forzamos a que use el usuario exacto con el que se hizo login en la web
\$username = isset(\$_SESSION["usuario"]) ? \$_SESSION["usuario"] : "asir_user";

// Asignamos la contraseña correspondiente del .env
if (\$username === "asir_admin") {
    \$password = "${DB_ADMIN_PASS}";
} else {
    \$username = "asir_user"; // Aseguramos limpieza en el string
    \$password = "${DB_LIMIT_PASS}";
}

\$database = isset(\$_SESSION["database"]) ? \$_SESSION["database"] : "database_rrhh";

// Intentar la conexión real
\$conn = new mysqli(\$servername, \$username, \$password, \$database);

// Si falla, nos muestra un diagnóstico completo en el navegador
if (\$conn->connect_error) {
    die("<b>Error de Conexión en Auditoría:</b><br>" .
        "Usuario Web/MySQL detectado: <u>" . \$username . "</u><br>" .
        "Base de datos solicitada: <u>" . \$database . "</u><br>" .
        "Detalle del error: " . \$conn->connect_error);
}
?>
EOF

echo "====================================="
echo " CONFIGURANDO PERMISOS "
echo "====================================="

# Cambia propietario Apache
sudo chown -R www-data:www-data /var/www/html

# Asigna permisos seguros
sudo chmod -R 755 /var/www/html


echo "====================================="
echo " COMPROBANDO SINTAXIS PHP "
echo "====================================="

# Comprueba sintaxis PHP
find /var/www/html -name "*.php" -exec php -l {} \;


echo "====================================="
echo " REINICIANDO APACHE "
echo "====================================="

# Reinicia Apache
sudo systemctl restart apache2


echo "====================================="
echo " VERIFICANDO APACHE "
echo "====================================="

# Comprueba Apache
sudo systemctl status apache2 --no-pager


echo "====================================="
echo " DESPLIEGUE COMPLETADO "
echo "====================================="