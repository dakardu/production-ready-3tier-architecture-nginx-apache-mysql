# Documentación de la conexion de los Servidores Apache con el Servidor de Base de Datos (DB)

## 1. Servidores Backend Apache

| Servidor | Hostname | IP            |
| -------- | -------- | ------------- |
| Apache 0 | apache0  | 192.168.1.108 |
| Apache 1 | apache1  | 192.168.1.122 |
| Apache 2 | apache2  | 192.168.1.123 |

Todos ejecutan:

-   Apache HTTPD 2.4.63
-   PHP 8.3.19
-   AlmaLinux

---

## 2. Instalación de Apache y PHP

```bash
sudo dnf install httpd -y
sudo systemctl enable --now httpd

sudo dnf install php php-mysqlnd php-cli php-common -y
sudo systemctl restart httpd

3. Ubicación de la aplicación PHP
/var/www/html/netsservices


Estructura organizada en:

/netsservices
 ├── config/
 │    └── conexion.php      ← archivo de conexión a la DB
 ├── controllers/
 ├── db/
 │    └── netservices.sql   ← estructura de la base de datos
 ├── public/
 │    ├── index.php
 │    ├── assets/
 │    └── .htaccess
 ├── views/
 ├── vendor/                ← dependencias cargadas con Composer
 ├── .env                   ← variables de entorno (credenciales)
 └── composer.json


4. Uso de archivo .env para credenciales

Ejemplo:

DB_HOST=192.168.1.126
DB_USER=devuser
DB_PASSWORD=********
DB_NAME=app_web

5. Archivo de conexión: config/conexion.php
<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once __DIR__.'/../vendor/autoload.php';

use Dotenv\Dotenv;

$dotenv_path = __DIR__ . '/../';
if (file_exists($dotenv_path . '.env')) {
    $dotenv = Dotenv::createUnsafeImmutable($dotenv_path);
    $dotenv->load();
}

function getEnvVar($key) {
    return $_ENV[$key] ?? getenv($key) ?? $_SERVER[$key] ?? null;
}

$host = getEnvVar('DB_HOST') ?? '192.168.1.126';
$user = getEnvVar('DB_USER') ?? 'devuser';
$password = getEnvVar('DB_PASSWORD') ?? '';
$dbname = getEnvVar('DB_NAME') ?? 'app_web';

$conexion = new mysqli($host, $user, $password, $dbname);

if ($conexion->connect_error) {
    error_log("✖ Error de conexión: " . $conexion->connect_error);
    die("No se pudo conectar a la base de datos. Intenta más tarde.");
}
?>

6. Prueba de consulta
<?php
require "config/conexion.php";

$sql = "SELECT * FROM usuarios";
$result = $conexion->query($sql);

while($row = $result->fetch_assoc()) {
   echo $row["id"] . " - " . $row["nombre"] . "<br>";
}
?>

7. Validación desde navegador
http://192.168.1.108/consulta.php
http://192.168.1.122/consulta.php
http://192.168.1.123/consulta.php


✔ Todos conectan correctamente a la DB.

8. Estado del backend

Todos los Apache funcionan y están listos para integrarse con NGINX.
```
