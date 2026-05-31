#!/bin/bash
set -e

echo "====================================================="
echo "  ORQUESTRADOR MYSQL SIMPLIFICADO FIABLE (.ENV)     "
echo "====================================================="

# 1. Cargamos el archivo .env directamente
source .env

# Exportamos para asegurar que sudo lea las variables correctamente
export DIR_BBDD NAME_DB_RRHH NAME_DB_TIENDA DB_ADMIN_USER DB_ADMIN_PASS DB_LIMIT_USER DB_LIMIT_PASS SQL_RRHH SQL_TIENDA

# =====================================================
# 2. GESTIÓN Y CREACIÓN DE LOS USUARIOS
# =====================================================
echo "[+] Configurando usuarios en el sistema..."

sudo mysql -e "DROP USER IF EXISTS '${DB_ADMIN_USER}'@'localhost';"
sudo mysql -e "CREATE USER '${DB_ADMIN_USER}'@'localhost' IDENTIFIED BY '${DB_ADMIN_PASS}';"

sudo mysql -e "DROP USER IF EXISTS '${DB_LIMIT_USER}'@'localhost';"
sudo mysql -e "CREATE USER '${DB_LIMIT_USER}'@'localhost' IDENTIFIED BY '${DB_LIMIT_PASS}';"

# =====================================================
# 3. DESPLIEGUE Y ASIGNACIÓN DE LA BBDD RRHH
# =====================================================
echo "[+] Importando base de datos: ${SQL_RRHH}"
sudo mysql < "${DIR_BBDD}/${SQL_RRHH}"

echo "[+] Asignando permisos para: ${NAME_DB_RRHH}"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON \`${NAME_DB_RRHH}\`.* TO '${DB_ADMIN_USER}'@'localhost';"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE ON \`${NAME_DB_RRHH}\`.* TO '${DB_LIMIT_USER}'@'localhost';"

# =====================================================
# 4. DESPLIEGUE Y ASIGNACIÓN DE LA BBDD TIENDA
# =====================================================
echo "[+] Importando base de datos: ${SQL_TIENDA}"
sudo mysql < "${DIR_BBDD}/${SQL_TIENDA}"

echo "[+] Asignando permisos para: ${NAME_DB_TIENDA}"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON \`${NAME_DB_TIENDA}\`.* TO '${DB_ADMIN_USER}'@'localhost';"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE ON \`${NAME_DB_TIENDA}\`.* TO '${DB_LIMIT_USER}'@'localhost';"

# =====================================================
# 5. APLICAR CAMBIOS
# =====================================================
sudo mysql -e "FLUSH PRIVILEGES;"
echo "====================================================="
echo "[+] ¡Despliegue multiusuario completado con éxito!  "
echo "====================================================="