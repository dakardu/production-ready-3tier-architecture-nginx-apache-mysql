# Documentación de Configuración NFS entre Apache0, Apache1 y Apache2

## 1. Introducción
Este documento describe el proceso completo para configurar un servidor **NFS en Apache0** y montarlo correctamente en **Apache1** y **Apache2**, con el fin de compartir el directorio `/var/www/html/netservices` entre las máquinas del laboratorio.

Incluye:
- Instalación de paquetes necesarios
- Configuración del servidor NFS
- Exportación de directorios
- Configuración SELinux
- Reglas de firewall
- Montaje del recurso NFS en clientes
- Solución de problemas comunes
- Validaciones finales

---

## 2. Instalación de NFS en Apache0 (servidor)

```bash
sudo dnf install -y nfs-utils
```

Verificar servicio:
```bash
sudo systemctl status nfs-server
```

---

## 3. Crear y configurar carpeta a exportar

La carpeta a compartir es:

```
/var/www/html/netservices
```

Asegurar permisos adecuados:

```bash
sudo chown -R apache:apache /var/www/html/netservices
sudo chmod -R 755 /var/www/html/netservices
```

---

## 4. Configuración de `/etc/exports`

Editar el archivo:

```bash
sudo nano /etc/exports
```

Agregar:

```
/var/www/html/netservices 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

Aplicar exportación:

```bash
sudo exportfs -rav
```

Verificar:

```bash
showmount -e
```

---

## 5. Configuración de SELinux

Habilitar políticas necesarias:

```bash
sudo setsebool -P use_nfs_home_dirs on
sudo setsebool -P virt_use_nfs on
sudo setsebool -P httpd_use_nfs on
sudo setsebool -P allow_ftpd_use_nfs on
sudo setsebool -P nfs_export_all_rw on
sudo setsebool -P nfs_export_all_ro on
```

---

## 6. Configuración del firewall en Apache0

Habilitar servicios:

```bash
sudo firewall-cmd --add-service=nfs --permanent
sudo firewall-cmd --add-service=mountd --permanent
sudo firewall-cmd --add-service=rpc-bind --permanent
sudo firewall-cmd --reload
```

Validar:

```bash
sudo firewall-cmd --list-all
```

---

## 7. Habilitar servicios NFS

```bash
sudo systemctl enable --now nfs-server rpcbind rpc-statd
```

Validar:

```bash
systemctl status nfs-server
systemctl status rpcbind
systemctl status rpc-statd
```

---

## 8. Instalación NFS en Apache1 y Apache2 (clientes)

```bash
sudo dnf install -y nfs-utils
```

---

## 9. Crear punto de montaje en Apache1 y Apache2

```bash
sudo mkdir -p /var/www/html/netservices
```

---

## 10. Montar la carpeta NFS

```bash
sudo mount -t nfs -o vers=3 192.168.1.108:/var/www/html/netservices /var/www/html/netservices
```

Para verificar:

```bash
df -h
```

---

## 11. Hacer el montaje persistente

Editar:

```bash
sudo nano /etc/fstab
```

Agregar:

```
192.168.1.108:/var/www/html/netservices /var/www/html/netservices nfs defaults,_netdev,vers=3 0 0
```

Probar:

```bash
sudo mount -a
```

---

## 12. Solución de problemas

### ❌ *Error: No route to host*
Causas:
- Firewall bloqueando NFS
- IP mal escrita
- NFS no exportado

Solución:
```bash
sudo firewall-cmd --add-service=nfs --permanent
sudo firewall-cmd --reload
showmount -e 192.168.1.108
```

### ❌ *Active (exited) en nfs-server*
Esto es normal en AlmaLinux 9, el servicio exporta y sale.  
Validar con:

```bash
rpcinfo -p
```

### ❌ Permisos incorrectos
```bash
sudo chown -R apache:apache /var/www/html/netservices
sudo chmod -R 755 /var/www/html/netservices
```

---

## 13. Validaciones finales

### En servidor Apache0:
```bash
showmount -e
rpcinfo -p
```

### En clientes:
```bash
df -h
ls -la /var/www/html/netservices
```

Si todo está correcto, los 3 servidores estarán compartiendo exactamente el mismo directorio web.

---

## 14. Estado final esperado

- Apache0 exporta `/var/www/html/netservices`
- Apache1 y Apache2 montan la carpeta por NFS
- SELinux configurado
- Firewall permitido
- Montaje persistente en fstab
- Aplicaciones PHP funcionando con el mismo código en todos los Apache

---
