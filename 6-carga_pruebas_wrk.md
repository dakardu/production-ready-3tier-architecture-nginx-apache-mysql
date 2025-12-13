# Guía para realizar pruebas de carga con wrk y monitoreo con Netdata

Este documento describe el proceso de instalación de `wrk`, Docker y Netdata para realizar pruebas de carga y monitorear el rendimiento del sistema.

## 1. Actualizar el sistema

```bash
sudo dnf update -y
```

## 2. Instalar los paquetes necesarios y el repositorio de Docker

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf update
```

## 3. Instalar Docker Engine

```bash
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## 4. Iniciar y habilitar el servicio Docker

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## 5. Instalar `wrk` usando Docker

Para ejecutar `wrk` como contenedor Docker, usa el siguiente comando:

```bash
sudo docker run --rm skandyla/wrk -t12 -c400 -d30s http://192.168.1.124
```

Donde:

-   `-t12`: 12 threads (hilos de ejecución).
-   `-c400`: 400 conexiones simultáneas.
-   `-d30s`: duración de la prueba de 30 segundos.
-   La URL de tu servidor es `http://192.168.1.124` (deberás ajustarla a la IP de tu servidor).

## 6. Instalar y configurar Netdata

Para instalar Netdata, se recomienda usar el script oficial de Netdata. Si utilizas una distribución basada en RHEL o CentOS, puedes instalarlo de la siguiente manera:

```bash
curl -Ss https://my-netdata.io/kickstart.sh | bash
```

### Nota:

Si ves un error al ejecutar este script, puedes usar el siguiente método alternativo para instalar Netdata:

```bash
sudo bash <(curl -Ss https://get.netdata.cloud/kickstart.sh)
```

## 7. Acceder al dashboard de Netdata

Una vez que Netdata esté instalado, abre tu navegador web y accede al dashboard de Netdata:

```
http://<IP_del_servidor>:19999
```

**Nota importante**: Si el puerto 19999 está bloqueado en el firewall, debes abrirlo para poder acceder al dashboard de Netdata. Para hacerlo, usa el siguiente comando:

```bash
sudo firewall-cmd --add-port=19999/tcp --permanent
sudo firewall-cmd --reload
```

## 7.1 Configurar límites de descriptores de archivo

Abre el archivo `/etc/security/limits.conf` y agrega las siguientes líneas al final:

```bash
* soft nofile 100000
* hard nofile 100000
```

## 7.2 Pruebas realizadas para ver el estres al que se enfrenta el servidor, devemos manejar los limites dentro

## de esta imagen ya que sin ese parametro nos lanza errores de descriptores

```bash
sudo docker run --rm --ulimit nofile=524288:524288 skandyla/wrk -t12 -c800 -d60s http://192.168.1.124
sudo docker run --rm --ulimit nofile=524288:524288 skandyla/wrk -t32 -c1600 -d120s http://192.168.1.124
sudo docker run --rm --ulimit nofile=524288:524288 skandyla/wrk -t64 -c10000 -d60s http://192.168.1.124
sudo docker run --rm --ulimit nofile=524288:524288 skandyla/wrk -t64 -c10000 -d120s http://192.168.1.124
```

Este paso es esencial para poder ver el monitoreo de recursos en tiempo real en el dashboard de Netdata.
![Al iniciar el dashboard](/images/netdata-dashboard.png)
![Aqui podemos ver la CPU y demas](/images/test1.png)
![Seguimos viendo metricas](/images/test2.png)
![Seguimos viendo como sube la carga](/images/test3.png)
![Vemos alertas de como se va estresando el servidor](/images/test4-estresRAM.png)
![Realizamos un test con mas carga y vemos el estres del servidor](/images/test-alto.png)

## 8. Interpretar las métricas de Netdata

En el dashboard de Netdata podrás visualizar métricas importantes como:

-   **CPU**: Uso de la CPU en porcentaje.
-   **Memoria RAM**: Uso de la memoria RAM en porcentaje.
-   **Red**: Métricas de tráfico de red.
-   **Disco**: Estadísticas de lectura y escritura en disco.

### Ejemplo de resultados del dashboard durante una prueba de carga:

![Dashboard de Netdata](https://example.com/dashboard-example.png) # Reemplazar por una captura de pantalla real si es necesario.

## 9. Notificaciones y alertas de Netdata

Netdata te notificará sobre problemas en el rendimiento del sistema, como sobrecarga de la CPU o falta de memoria. En el caso de que se superen ciertos umbrales, aparecerán alertas en el dashboard.

---

**Nota**: Puedes ajustar la configuración de Netdata y los límites de alerta desde el archivo de configuración para que se adapten mejor a tu infraestructura y necesidades de monitoreo.

Con esta configuración podrás realizar pruebas de carga eficaces con `wrk`, monitorear el rendimiento con `Netdata` y obtener alertas en caso de problemas.

```

```
