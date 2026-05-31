#!/bin/bash
# Salir inmediatamente si un comando falla
set -ex

echo "====================================="
echo " ASEGURANDO CONEXIÓN ANTES DE LIMPIAR "
echo "====================================="

# 1. Primero aseguramos que la política por defecto sea ACCEPT 
# para que no nos eche al vaciar las reglas.
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

echo "====================================="
echo " LIMPIANDO REGLAS ANTERIORES "
echo "====================================="

sudo iptables -F
sudo iptables -X
sudo iptables -Z

echo "====================================="
echo " PERMITIENDO TRAFICO LOCAL Y CONEXIONES ACTIVAS "
echo "====================================="

# Permitir localhost
sudo iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones ya establecidas y relacionadas (Crucial para no perder SSH)
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "====================================="
echo " CONFIGURANDO PUERTOS PERMITIDOS "
echo "====================================="

# Permitir acceso SSH (Puerto 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir Web (HTTP y HTTPS)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

echo "====================================="
echo " LIMITANDO ICMP (PING) "
echo "====================================="

# Limita peticiones ping
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

echo "====================================="
echo " APLICANDO POLÍTICAS DE BLOQUEO POR DEFECTO "
echo "====================================="

#Lo que no coincida con lo anterior, SE CONFIGURA COMO DROP.
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT # Permitimos salida libre desde el servidor

echo "====================================="
echo " MOSTRANDO REGLAS ACTIVAS "
echo "====================================="

sudo iptables -L -n -v
