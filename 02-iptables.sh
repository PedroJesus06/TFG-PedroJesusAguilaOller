#!/bin/bash
set -ex

echo "====================================="
echo " LIMPIANDO REGLAS ANTERIORES "
echo "====================================="

# Elimina todas las reglas actuales de la tabla FILTER
sudo iptables -F

# Elimina cadenas personalizadas creadas anteriormente
sudo iptables -X

# Reinicia contadores de paquetes y tráfico
sudo iptables -Z

# Limpia reglas de la tabla NAT
sudo iptables -t nat -F

# Limpia reglas de la tabla MANGLE
sudo iptables -t mangle -F


echo "====================================="
echo " CONFIGURANDO POLITICAS POR DEFECTO "
echo "====================================="

# Bloquea todo el tráfico entrante por defecto
sudo iptables -P INPUT DROP

# Bloquea el reenvío de paquetes
sudo iptables -P FORWARD DROP

# Permite todas las conexiones salientes
sudo iptables -P OUTPUT ACCEPT


echo "====================================="
echo " PERMITIENDO TRAFICO LOCAL "
echo "====================================="

# Permite tráfico interno del propio servidor (localhost)
sudo iptables -A INPUT -i lo -j ACCEPT


echo "====================================="
echo " PERMITIENDO CONEXIONES ESTABLECIDAS "
echo "====================================="

# Permite paquetes pertenecientes a conexiones ya iniciadas
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


echo "====================================="
echo " CONFIGURANDO SSH "
echo "====================================="

# Permite acceso SSH remoto al servidor
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT


echo "====================================="
echo " CONFIGURANDO IP AUTORIZADA "
echo "====================================="

# Define la IP autorizada para acceder a la aplicación web
IP_AUTORIZADA="192.168.1.50"


echo "====================================="
echo " CONFIGURANDO ACCESO WEB "
echo "====================================="

# Permite acceso HTTP únicamente desde la IP autorizada
sudo iptables -A INPUT -p tcp -s $IP_AUTORIZADA --dport 80 -j ACCEPT

# Permite acceso HTTPS únicamente desde la IP autorizada
sudo iptables -A INPUT -p tcp -s $IP_AUTORIZADA --dport 443 -j ACCEPT


echo "====================================="
echo " BLOQUEANDO MYSQL EXTERNO "
echo "====================================="

# Bloquea cualquier intento de acceso externo al puerto MySQL
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP


echo "====================================="
echo " PROTECCION CONTRA PING "
echo "====================================="

# Bloquea peticiones ICMP para evitar respuestas a ping
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP


echo "====================================="
echo " INSTALANDO IPTABLES-PERSISTENT "
echo "====================================="

# Instala el servicio para mantener reglas tras reinicio
sudo apt install iptables-persistent -y


echo "====================================="
echo " GUARDANDO REGLAS "
echo "====================================="

# Guarda permanentemente las reglas actuales
sudo netfilter-persistent save


echo "====================================="
echo " MOSTRANDO REGLAS ACTIVAS "
echo "====================================="

# Muestra todas las reglas configuradas actualmente
sudo iptables -L -n -v


echo "====================================="
echo " FIREWALL CONFIGURADO CORRECTAMENTE "
echo "====================================="
```
