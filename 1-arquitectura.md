# Documentación del Laboratorio: Apache, NGINX, SQL con Balanceo de Carga

## 1. Objetivo y Alcance del Laboratorio

El objetivo principal de este laboratorio es comprender, implementar y probar un entorno web distribuido compuesto por múltiples servidores Apache que ejecutan una aplicación PHP, los cuales son gestionados mediante un balanceador de carga basado en NGINX. Además, la aplicación accede a una base de datos SQL alojada en un servidor independiente, permitiendo simular un entorno real de arquitectura web multi-capa.

Este laboratorio permite al administrador:

Analizar el comportamiento del balanceo de carga entre tres servidores web.

Observar cómo cada servidor Apache responde de forma independiente ejecutando la misma aplicación.

Validar que la aplicación mantiene la funcionalidad al consultar una base de datos centralizada.

Entender el flujo cliente → proxy inverso → servidores Apache → base de datos.

Preparar la infraestructura para escenarios reales como alta disponibilidad, escalabilidad horizontal, y desacoplamiento de capas.

## 1.1 Arquitectura del entorno

La arquitectura implementada corresponde a un esquema clásico de 3 capas:

Capa de presentación: Cliente (navegador).

Capa intermedia (proxy inverso / balanceador): Servidor NGINX.

Capa de aplicación: 3 servidores Apache ejecutando la misma app PHP.

Capa de datos: Servidor SQL independiente.

(La imagen utilizada es equivalente al diagrama que proporcionaste en tu archivo.)

## 1.2 Tecnologías y herramientas utilizadas

Para la implementación del laboratorio se utilizaron las siguientes herramientas:

Sistemas Operativos

AlmaLinux en todas las VMs (servidores Apache, NGINX y SQL).

Todas las máquinas fueron previamente:

Actualizadas

Configuradas con IP estática

Integradas en la misma red

Servidores Web

Apache HTTP Server (en 3 máquinas independientes)

Ejecutando una aplicación PHP simple que permite identificar el servidor.

Balanceador y Proxy Inverso

NGINX, configurado como:

Reverse Proxy

Balanceador Round Robin

Orquestación del tráfico hacia los 3 Apache

Base de Datos

Servidor independiente con SQL Server / MariaDB / MySQL (según configuración del laboratorio).

Acceso remoto permitido para la app.

Infraestructura

5 máquinas virtuales creadas en un entorno de virtualización (Hyper-V, VMware, Proxmox o similar).

Red interna configurada para permitir comunicación entre servicios.

## 2. Arquitectura del Laboratorio

A continuación se presenta el diagrama de arquitectura proporcionado por el usuario:

```
      ┌─────────┐
      │  Cliente │
      └────┬────┘
           │
           ▼
   ┌──────────────┐
   │   NGINX LB    │  ← reverse proxy + balanceo
   └──────┬────────┘
     ┌────┴───────┬──────┐
     ▼             ▼       ▼
┌────────┐   ┌────────┐   ┌────────┐
│ Apache │   │ Apache │   │ Apache │  ← 3 apps en 3 VMs
└────┬───┘   └───┬────┘   └───┬────┘
     │           │            │
     └───────────┴────────────┘
                 ▼
          ┌──────────┐
          │   SQL DB  │
          └──────────┘
```

## 3. Justificación del uso de AlmaLinux

AlmaLinux fue elegido por su compatibilidad total 1:1 con RHEL, estabilidad empresarial, soporte a largo plazo, comunidad activa y ausencia de costes de licencia.  
Es ideal para laboratorios de servidores web, proxys inversos, bases de datos y entornos de virtualización.

## 4. Infraestructura del Laboratorio

| VM  | Hostname | Rol                | IP            | vCPUs | RAM     |
| --- | -------- | ------------------ | ------------- | ----- | ------- |
| VM0 | apache0  | Servidor Apache    | 192.168.1.108 | 16    | 3.6 GiB |
| VM1 | apache1  | Servidor Apache    | 192.168.1.122 | 16    | 1.6 GiB |
| VM2 | apache2  | Servidor Apache    | 192.168.1.123 | 16    | 1.6 GiB |
| VM3 | nginx    | Reverse Proxy / LB | 192.168.1.124 | 16    | 1.6 GiB |
| VM4 | DB       | Servidor SQL       | 192.168.1.126 | 16    | 1.6 GiB |

## 5. Versiones de Software

### Apache

Versión detectada: **Apache 2.4.63**

### PHP

Versión detectada: **PHP 8.3.19**

### NGINX

Versión detectada: **NGINX 1.26.3**

### MariaDB / MySQL

Versión detectada: **MariaDB 10.11.11**

## 6. Configuración pendiente

El laboratorio continuará con:

-   Configuración del balanceo de carga NGINX
-   Pruebas de funcionamiento entre los 3 servidores Apache
-   Validación de acceso a la base de datos
-   Simulaciones de fallo y comportamiento del balanceador
