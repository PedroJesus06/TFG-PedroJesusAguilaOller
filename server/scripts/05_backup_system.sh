#!/bin/bash
# Cargar variables
source ../.env

echo "Iniciando copia de seguridad de todas las bases de datos..."

# Asegurar que exista la carpeta y hacer el volcado directo
mkdir -p "$BACKUP_DIR"
mysqldump --all-databases --single-transaction --quick | gzip > "$BACKUP_DIR/$BACKUP_NAME"

echo "Copia de seguridad finalizada con éxito en $BACKUP_DIR/$BACKUP_NAME"