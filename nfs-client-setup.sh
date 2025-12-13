#!/bin/bash
#
# Script de configuración automática de un cliente NFS
# Autor: Dagoberto Duran Montoya (Lab Apache + Nginx + SQL)
# Fecha: 2025
#
# Uso:
#   sudo bash nfs-client-setup.sh <IP_SERVIDOR_NFS> <RUTA_REMOTA> <RUTA_LOCAL>
#
# Ejemplo:
#   sudo bash nfs-client-setup.sh 192.168.1.108 /var/www/html/netservices /var/www/html/netservices
#

# Validación de parámetros
if [ $# -ne 3 ]; then
    echo "Uso: sudo bash $0 <IP_SERVIDOR_NFS> <RUTA_REMOTA> <RUTA_LOCAL>"
    exit 1
fi

NFS_SERVER_IP=$1
NFS_REMOTE_DIR=$2
NFS_LOCAL_DIR=$3

echo "=============================================="
echo " Configurando Cliente NFS"
echo " Servidor: $NFS_SERVER_IP"
echo " Carpeta remota: $NFS_REMOTE_DIR"
echo " Carpeta local: $NFS_LOCAL_DIR"
echo "=============================================="

# Instalación de paquetes necesarios
echo "[1/6] Instalando paquetes NFS..."
dnf install -y nfs-utils >/dev/null 2>&1

# Crear carpeta local
echo "[2/6] Creando carpeta local si no existe..."
mkdir -p "$NFS_LOCAL_DIR"

# Configuración de SELinux
echo "[3/6] Configurando SELinux..."
setsebool -P use_nfs_home_dirs on
setsebool -P virt_use_nfs on
setsebool -P httpd_use_nfs on
setsebool -P allow_ftpd_use_nfs on
setsebool -P nfs_export_all_rw on
setsebool -P nfs_export_all_ro on

# Montaje inmediato
echo "[4/6] Montando carpeta NFS..."
mount -t nfs -o vers=3 $NFS_SERVER_IP:$NFS_REMOTE_DIR $NFS_LOCAL_DIR

if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo montar el recurso NFS."
    echo "Revisa conectividad, firewall o SELinux."
    exit 1
fi

# Configuración persistente en /etc/fstab
echo "[5/6] Configurando montaje persistente..."
echo "$NFS_SERVER_IP:$NFS_REMOTE_DIR   $NFS_LOCAL_DIR   nfs   defaults,_netdev,vers=3   0  0" >> /etc/fstab

# Verificación final
echo "[6/6] Verificando montaje..."
mount | grep "$NFS_LOCAL_DIR"

echo "=============================================="
echo " ✔ Cliente NFS configurado exitosamente"
echo " ✔ Montaje activo y persistente al reinicio"
echo "=============================================="