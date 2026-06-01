#!/bin/bash
set -ex


echo "====================================="
echo " ASEGURANDO CONEXIÓN ANTES DE LIMPIAR "
echo "====================================="

# 1. Aseguramos política ACCEPT provisional en IPv4 e IPv6 para no perder el SSH
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

sudo ip6tables -P INPUT ACCEPT
sudo ip6tables -P FORWARD ACCEPT
sudo ip6tables -P OUTPUT ACCEPT


echo "====================================="
echo " LIMPIANDO REGLAS ANTERIORES "
echo "====================================="

sudo iptables -F && sudo iptables -X && sudo iptables -Z
sudo ip6tables -F && sudo ip6tables -X && sudo ip6tables -Z


echo "====================================="
echo " FILTRADO DE SEGURIDAD INICIAL "
echo "====================================="

# Descartar paquetes inválidos inmediatamente
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Permitir interfaz de lo (localhost)
sudo iptables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -i lo -j ACCEPT

# Permitir conexiones ya establecidas y relacionadas
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


echo "====================================="
echo " PROTECCIÓN ANTI FUERZA BRUTA SSH "
echo "====================================="

# Si intentan más de 3 conexiones SSH nuevas en 60 segundos, se registra y se bloquea esa IP temporalmente
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set --name SSH_CHECK
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name SSH_CHECK -j DROP


echo "====================================="
echo " CONFIGURANDO PUERTOS PERMITIDOS "
echo "====================================="

# -----------------------------------------------------------------
#Acceso a todo el mundo
# -----------------------------------------------------------------
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# -----------------------------------------------------------------
# Estas reglas son para limitar el acceso a los puertos solo desde la IP del instituto, pero las he comentado para no bloquearme el acceso a mí mismo durante las pruebas. 
#Si quieres usarlas, descoméntalas y pon tu IP real en la variable IP_INSTITUTO al principio del script.
# -----------------------------------------------------------------
# Permitir acceso SSH (Puerto 22) SOLO desde la IP elegida
#sudo iptables -A INPUT -p tcp -s "$IP" --dport 22 -j ACCEPT

# Permitir Web (HTTP 80 y HTTPS 443) SOLO desde la IP elegida
#sudo iptables -A INPUT -p tcp -s "$ip" --dport 80 -j ACCEPT
#sudo iptables -A INPUT -p tcp -s "$ip" --dport 443 -j ACCEPT

# -----------------------------------------------------------------
# MONITORIZACIÓN LOCAL (ZABBIX): Para evitar que dé alertas de caída
# -----------------------------------------------------------------
# Permitir tráfico local de Zabbix Agent y Server en la IP pública de AWS
sudo iptables -A INPUT -p tcp -s "$IP_SERVIDOR_AWS" --dport 10050 -j ACCEPT
sudo iptables -A INPUT -p tcp -s "$IP_SERVIDOR_AWS" --dport 10051 -j ACCEPT


echo "====================================="
echo " LIMITANDO ICMP (PING) "
echo "====================================="

# Limita peticiones ping entrantes para evitar saturación (DoS)
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 4 -j ACCEPT
sudo ip6tables -A INPUT -p ipv6-icmp -j ACCEPT # IPv6 requiere ICMP para su funcionamiento interno


echo "====================================="
echo " REGISTRO DE TRÁFICO BLOQUEADO (LOG) "
echo "====================================="

# Registra en syslog los paquetes denegados (máximo 5 logs por minuto para proteger el disco)
sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTABLES-DROP: " --log-level 7


echo "====================================="
echo " APLICANDO POLÍTICAS DE BLOQUEO POR DEFECTO "
echo "====================================="

# Cerramos todo lo que no haya coincidido con las reglas de acceso anteriores
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT # Permitimos salida libre desde el servidor hacia internet

sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT


echo "====================================="
echo " MOSTRANDO REGLAS ACTIVAS EN MEMORIA "
echo "====================================="

sudo iptables -L -n -v


echo "====================================="
echo " HACIENDO LAS REGLAS PERSISTENTES "
echo "====================================="

# Evitamos que salte la interfaz gráfica interactiva de configuración
export DEBIAN_FRONTEND=noninteractive

# Actualizamos repositorios e instalamos el paquete de persistencia de forma silenciosa
sudo -E apt-get update
sudo -E apt-get install -y iptables-persistent

# Volcamos a la fuerza las reglas que acabamos de meter en los archivos que se leen en el arranque
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
sudo sh -c "ip6tables-save > /etc/iptables/rules.v6"

echo "====================================="
echo " CORTAFUEGOS CONFIGURADO Y PERSISTENTE "
echo "====================================="