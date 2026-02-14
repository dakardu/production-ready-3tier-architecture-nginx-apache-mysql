# 🏗️ Production-Ready 3-Tier Web Architecture (On-Premise)

This project demonstrates a secure and scalable 3-tier architecture deployed across 5 virtual machines:

- 🔹 NGINX Reverse Proxy + Load Balancer
- 🔹 3x Apache Web Servers (Application Layer)
- 🔹 1x Isolated Database Server (MySQL/PostgreSQL)

The design enforces strict network segmentation and access control between tiers, following production-grade security practices.

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


## 🔐 Security Design

- Only NGINX is exposed to the internet
- Apache servers only accept traffic from NGINX
- Database server is isolated and only accessible from Apache tier
- No direct public access to application or database layers


## ⚙️ Tech Stack

- NGINX (Reverse Proxy / Load Balancer)
- Apache HTTP Server
- Linux (Ubuntu / AlmaLinux)
- Virtual Machines
- Network segmentation

## 🧪 Results / Tests

- Logs
- Trafico Balanceo
- Metricas


Sigue las instrucciones en cada archivo para configurar y realizar las pruebas correspondientes.
