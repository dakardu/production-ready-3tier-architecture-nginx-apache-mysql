# Documentación del Servidor de Base de Datos (DB)

Documentación del Servidor de Base de Datos (DB)

## 1. Información General del Servidor DB

El servidor de base de datos forma parte fundamental de la arquitectura del laboratorio Apache + NGINX + SQL.
Es responsable de gestionar los datos consumidos por la aplicación PHP distribuida en los servidores Apache.

Detalles del servidor:

Sistema Gestor: MariaDB 10.11.11

Dirección IP: 192.168.1.126

Hostname: DB

Usuario de acceso para la aplicación: devuser

## 2. Bases de Datos Disponibles

Para consultar las bases de datos existentes se ejecutó:

SHOW DATABASES;

Salida:

+--------------------+
| Database |
+--------------------+
| app_web |
| information_schema |
| mysql |
| performance_schema |
| sys |
+--------------------+

✔ La base de datos app_web es la utilizada por la aplicación web.
✔ El resto son bases internas del motor.

## 3. Selección de la Base de Datos app_web

USE app_web;

Resultado:

Database changed

## 4. Tablas Existentes en app_web

Para listar las tablas:

SHOW TABLES;

Salida:

+--------------------+
| Tables_in_app_web |
+--------------------+
| usuarios |
+--------------------+

✔ Actualmente la base contiene una única tabla llamada usuarios, que será usada por la aplicación PHP.

## 5. Creación del Usuario de Base de Datos para la Aplicación

El usuario utilizado por la aplicación debe tener permisos sobre app_web, pero no sobre otras bases del sistema.
Además, debe poder autenticarse desde cualquier servidor Apache o desde NGINX.

## 5.1 Verificación inicial de usuarios existentes

SELECT user, host FROM mysql.user;

Salida:

+-------------+-----------+
| User | Host |  
+-------------+-----------+
| devuser | 127.0.0.1 |
| devuser | localhost |
| mariadb.sys | localhost |
| mysql | localhost |
| root | localhost |
+-------------+-----------+

## 5.2 Creación del usuario devuser para acceso desde la red interna

CREATE USER 'devuser'@'192.168.1.%' IDENTIFIED BY '**\*\*\*\***';

✔ Permite que el usuario se conecte desde cualquier host dentro del rango 192.168.1.X.
✔ Esto incluye a los tres servidores Apache y al NGINX.

## 5.3 Asignación de permisos sobre la base de datos app_web

GRANT ALL PRIVILEGES ON app_web.\* TO 'devuser'@'192.168.1.%';

✔ El usuario tiene permisos completos en la base de datos de la aplicación.
✔ No tiene permisos sobre bases del sistema (mysql, sys, etc.).

## 5.4 Aplicación de los cambios

FLUSH PRIVILEGES;

Esto actualiza la caché de permisos y hace efectivos los cambios.

## 5.5 Verificación final del usuario creado

SELECT user, host FROM mysql.user;

Salida final:

+-------------+--------------+
| User | Host |
+-------------+--------------+
| devuser | 127.0.0.1 |
| devuser | localhost |
| devuser | 192.168.1.% |
| mariadb.sys | localhost |
| mysql | localhost |
| root | localhost |
+-------------+--------------+

✔ Se confirma que devuser@192.168.1.% existe y está activo.
✔ El usuario ya puede ser utilizado por la aplicación PHP desde cualquier servidor del laboratorio.

## 6. Estado Actual del Servidor DB

| Elemento              | Estado                       |
| --------------------- | ---------------------------- |
| Motor SQL             | MariaDB 10.11.11             |
| Base de datos activa  | app_web                      |
| Tabla principal       | usuarios                     |
| Usuario de aplicación | devuser                      |
| Alcance de conexión   | 192.168.1.%                  |
| Permisos asignados    | ALL PRIVILEGES sobre app_web |

El servidor está completamente preparado para integrarse con los servidores Apache y la aplicación PHP.
