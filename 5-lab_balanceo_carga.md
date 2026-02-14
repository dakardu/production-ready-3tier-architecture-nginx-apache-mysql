
# Laboratorio de Balanceo de Carga (NGINX + Apache + SELinux)

## 1️⃣ Infraestructura del Laboratorio

| Servidor   | Rol                | IP               |
|------------|--------------------|------------------|
| Apache 0   | Backend 1          | 192.168.1.108    |
| Apache 1   | Backend 2          | 192.168.1.122    |
| Apache 2   | Backend 3          | 192.168.1.123    |
| NGINX      | Balanceador (LB)   | 192.168.1.124    |
| DB         | Base de Datos      | 192.168.1.xxx    |

Todos los Apache sirven la misma aplicación PHP conectada a una única base de datos.

---

## 2️⃣ Problemas detectados durante la implementación

### 🟥 Error principal: *502 Bad Gateway* en NGINX

El balanceador devolvía:
```
502 Bad Gateway
```

Pero todos los backends parecían funcionar:
```bash
curl -I http://192.168.1.108
curl -I http://192.168.1.122
curl -I http://192.168.1.123
```

Resultados: `HTTP/1.1 200 OK`

---

## 3️⃣ Causa 1 — SELinux bloqueando conexiones salientes

SELinux en modo *enforcing* no permite:

- Conexiones TCP entre servicios web  
- Reverse proxy hacia backends internos  
- Uso de NGINX como balanceador  

Esto produce 502 silenciosos sin dejar trazas en `/var/log/nginx/error.log`.

### ✔ Solución aplicada

```bash
sudo setsebool -P httpd_can_network_connect 1
```

Resultado:  
NGINX pudo conectarse inmediatamente a los backends Apache.

---

## 4️⃣ Causa 2 — Apache0 tenía activo HTTPS y redireccionaba HTTP → HTTPS

En Apache0 (`192.168.1.108`) existía un VirtualHost para HTTPS en:

```
/etc/httpd/conf.d/default.conf
```

Este VirtualHost contenía un certificado self-signed y una redirección:

```apache
<VirtualHost *:80>
    ServerAlias 192.168.1.108
    Redirect permanent / https://192.168.1.108
</VirtualHost>
```

### ❗ Esto provocaba:

- Una redirección 301 a HTTPS  
- NGINX recibía un 301 en lugar de la respuesta de la aplicación  
- Como NGINX no estaba configurado para proxy HTTPS → devolvía 502  

### ✔ Corrección aplicada

Se desactivó la redirección:

```apache
# Redirect permanent / https://192.168.1.108
```

Se desactivó también el VirtualHost SSL que no era necesario en este laboratorio.

Reinicio:

```bash
sudo systemctl restart httpd
```

Resultado:  
Apache0 dejó de forzar HTTPS → NGINX pudo usar HTTP correctamente.

---

## 5️⃣ Configuración final del Balanceador NGINX

Archivo:
```
/etc/nginx/conf.d/loadbalancer.conf
```

Contenido:

```nginx
upstream backend_apache {
    server 192.168.1.108 max_fails=3 fail_timeout=30s;
    server 192.168.1.122 max_fails=3 fail_timeout=30s;
    server 192.168.1.123 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend_apache;

        proxy_connect_timeout 5s;
        proxy_read_timeout 30s;
        proxy_send_timeout 30s;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/loadbalancer_access.log;
    error_log  /var/log/nginx/loadbalancer_error.log warn;
}
```

Validación:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

## 6️⃣ Verificación final

```bash
curl -I http://192.168.1.124
```

Resultado:
```
HTTP/1.1 200 OK
```

Los tres backends reciben tráfico en Round Robin.

---

## 7️⃣ Próximos pasos del laboratorio

- [ ] Pruebas de carga con **wrk**
- [ ] Métricas de CPU, RAM y latencias
- [ ] Comparación con HAProxy
- [ ] Comparación con Apache mod_proxy_balancer
- [ ] Documentar arquitectura final del entorno

---
