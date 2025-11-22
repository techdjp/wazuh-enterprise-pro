# Checklist QA - Wazuh Enterprise Pro Installer v2.4

## Servicios
- [ ] wazuh-manager activo
- [ ] wazuh-indexer activo
- [ ] wazuh-dashboard activo

## Certificados
- [ ] root-ca.pem existe
- [ ] indexer.pem existe
- [ ] dashboard.pem existe
- [ ] manager-cert.pem existe
- [ ] Permisos y propietarios correctos

## Firewall
- [ ] Puertos 1514, 1515, 55000, 9200, 9300 abiertos
- [ ] SSH 50022 abierto

## Logs
- [ ] Archivo de log generado en logs/

## Indexación
- [ ] Verificar _cluster/health con admin y certificados
- [ ] Confirmar patrón de índice wazuh-alerts-* creado
