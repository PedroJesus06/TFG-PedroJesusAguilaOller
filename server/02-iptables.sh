#!/bin/bash
set -ex
echo "====================================="
echo " LIMPIANDO REGLAS ANTERIORES "
echo "====================================="

# Elimina todas las reglas activas de la tabla FILTER
sudo iptables -F

# Elimina cadenas personalizadas creadas anteriormente
sudo iptables -X

# Reinicia los contadores de tráfico y paquetes
sudo iptables -Z

# Elimina reglas de traducción NAT
sudo iptables -t nat -F

# Elimina reglas especiales de manipulación de paquetes
sudo iptables -t mangle -F


echo "====================================="
echo " CONFIGURANDO TRAFICO LOCAL "
echo "====================================="

# Permite el tráfico interno del propio servidor (localhost)
sudo iptables -A INPUT -i lo -j ACCEPT


echo "====================================="
echo " PERMITIENDO CONEXIONES ACTIVAS "
echo "====================================="

# Permite conexiones ya iniciadas y respuestas relacionadas
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


echo "====================================="
echo " CONFIGURANDO SSH "
echo "====================================="

# Permite conexiones SSH remotas al servidor
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT


echo "====================================="
echo " CONFIGURANDO SERVIDOR WEB "
echo "====================================="

# Permite tráfico HTTP para acceder a la aplicación web
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permite tráfico HTTPS para conexiones seguras
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT


echo "====================================="
echo " BLOQUEANDO MYSQL EXTERNO "
echo "====================================="

# Bloquea cualquier acceso externo al puerto MySQL
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP


echo "====================================="
echo " LIMITANDO PETICIONES ICMP "
echo "====================================="

# Limita peticiones ping para reducir ataques ICMP
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT


echo "====================================="
echo " APLICANDO POLITICAS DE SEGURIDAD "
echo "====================================="

# Bloquea por defecto cualquier conexión entrante no permitida
sudo iptables -P INPUT DROP

# Bloquea el reenvío de paquetes entre interfaces
sudo iptables -P FORWARD DROP

# Permite todas las conexiones salientes del servidor
sudo iptables -P OUTPUT ACCEPT


echo "====================================="
echo " INSTALANDO PERSISTENCIA "
echo "====================================="

# Instala el servicio que mantiene las reglas tras reiniciar
sudo apt install iptables-persistent -y


echo "====================================="
echo " GUARDANDO CONFIGURACION "
echo "====================================="

# Guarda permanentemente las reglas actuales
sudo netfilter-persistent save


echo "====================================="
echo " MOSTRANDO REGLAS ACTIVAS "
echo "====================================="

# Muestra todas las reglas activas del firewall
sudo iptables -L -n -v


echo "====================================="
echo " FIREWALL CONFIGURADO "
echo "====================================="
