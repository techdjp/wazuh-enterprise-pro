# wazuh-enterprise-pro
Wazuh Enterprise Pro Installer es un script automatizado para desplegar Wazuh Manager, Indexer y Dashboard en Ubuntu 24.04 LTS, optimizado para entornos de prueba y producción.

Le presentamos nuestro producto en su fase inicial. Su propósito es la validación de sus funciones y operativa antes de la puesta en funcionamiento completa. Agradecemos enormemente su tiempo para evaluar los resultados detallados y confirmar su efectividad. Su feedback es clave para esta etapa. 

¡Gracias por participar y por sus comentarios!

<img width="3804" height="1802" alt="image" src="https://github.com/user-attachments/assets/75b255e1-2b7c-4b44-82c2-224f77cc722e" />


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Resultados esperados QA

| Item                  | Esperado                                            |
| --------------------- | --------------------------------------------------- |
| Servicios activos     | `wazuh-indexer`, `wazuh-dashboard`, `wazuh-manager` |
| Certificados          | Existentes, válidos y permisos correctos            |
| Firewall              | Solo puertos necesarios abiertos                    |
| Logs                  | Completos con auditoría de permisos y servicios     |
| Dashboard             | Login admin:admin y acceso SSL sin errores          |
| Agentes               | Detectados correctamente (si se instalan)           |
| Reinicio del servidor | Servicios inician automáticamente                   |


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Documentación Técnica Final del Script v2.4 QA

1. General

    Nombre: Wazuh Enterprise Pro v2.4 QA
    Empresa: Branchcore Technology C.A.
    División: SARYAD (R&D / DevOps)
    Propósito: Automatizar instalación de Wazuh 4.x con auditoría, firewall mínimo y certificados personalizados.

2. Componentes instalados

    Componente Versión Observaciones
    Wazuh Indexer	4.x	Localhost, SSL con CA personalizada
    Wazuh Dashboard	4.x	Certificados copiados desde Indexer
    Wazuh Manager	4.x	Certificados Manager creados

4. Certificados

    CA raíz: /etc/wazuh-indexer/certs/wazuh-root-ca.pem
    Indexer: /etc/wazuh-indexer/certs/indexer.pem
    Dashboard: /etc/wazuh-dashboard/certs/dashboard.pem
    Manager: /var/ossec/etc/sslmanager/manager-cert.pem
    DN: O=SARYAD/OU=R&D DevOps/CN=...
    Validez: 3650 días (personalizable)

4. Permisos

    Indexer: propietario wazuh-indexer, permisos 400/500.
    Dashboard: propietario wazuh-dashboard, permisos 640/750.
    Manager: propietario wazuh, permisos 400/750.

5. Firewall

    Puertos abiertos: 1514, 1515, 55000, 9200, 9300, 50022
    Todo lo demás bloqueado.

6. Auditoría y logs
   
    Log principal: /var/log/wazuh_install_enterprise_pro.log
    Auditoría automática de:
    Servicios
    Directorios y archivos
    Firewall
    Certificados

8. QA y validación

    Pruebas de comunicación SSL.
    Login Dashboard con admin/admin.
    Reinicio automático de servicios tras reboot.
    Scripts repetibles para múltiples entornos de QA.

# Plan de Validación y QA para el Script Enterprise Pro Wazuh v2.4

1️⃣ Entorno Base

    Sistema operativo: Ubuntu 24.04 LTS (confirmado como plataforma de despliegue).
    Servidores de prueba: separados en QA para replicar producción.
    Servicios previos: Wazuh Indexer, Wazuh Dashboard y Wazuh Manager.

2️⃣ Validación Pre-Instalación

    Comprobar privilegios root.
    Auditoría de directorios y archivos críticos:
      /etc/wazuh-indexer/certs
      /etc/wazuh-dashboard/certs
      /var/ossec/etc/sslmanager
    Validación de paquetes necesarios: curl, openssl, ufw, openscap-scanner, etc.
    Confirmación de que la CA y certificados previos existen o se generarán correctamente.

3️⃣ Ejecución del Script

    Script v2.4 ejecutado con opciones automatizadas o manuales según QA.
    Variables controladas:
      Tiempo de validez de certificados.
      Campos del DN (para personalización opcional de la CA).
      Usuarios y permisos de archivos y carpetas.
    Registro de logs completo en /var/log/wazuh_install_enterprise_pro.log.

4️⃣ Post-Instalación QA

    Servicios
    wazuh-indexer, wazuh-dashboard, wazuh-manager activos.
    Reinicio automático confirmado.
    Certificados
    CA raíz (wazuh-root-ca.pem) y certificados de nodos generados correctamente.
    Permisos y propiedad verificados.
    Firewall
    Puertos abiertos: 1514, 1515, 55000, 9200, 9300, 50022.
    Conectividad
    Comprobación de conexión entre agentes y manager.
    Prueba de login en dashboard con admin/admin.
    Validación de índices
    wazuh-alerts-* presentes en Wazuh Indexer.
    Prueba de refresco de datos en dashboard.

5️⃣ Auditoría QA

    Reporte automático al finalizar:
    Estado de servicios.
    Directorios y permisos.
    Certificados creados y validados.
    Puertos abiertos.
    Resultados de perfil CIS/OpenSCAP (si está disponible).
    Versión de Ubuntu y Wazuh instalados.
    Tiempo de instalación y log completo de pasos.

6️⃣ Automatización QA

    Crear un checkpoint de QA:
    Antes de reiniciar el servidor.
    Después de reiniciar: script comprueba que todos los servicios vuelven a iniciar y que los certificados son válidos.
    Opciones del script:
      --run-full-install → Instala todo y genera log.
      --run-check → Solo auditoría y validación QA.
      --recreate-certs → Permite regenerar certificados desde la CA.

<img width="3805" height="1805" alt="image" src="https://github.com/user-attachments/assets/79bf3607-ac09-4156-94da-d09995334d0b" />
