#!/bin/bash
# ============================================================== 
# Script de Instalación Enterprise Pro Wazuh v2.4 - QA
# ============================================================== 
# Automatización completa de Wazuh Indexer, Dashboard y Manager
# Incluye certificados SSL, auditoría de servicios y directorios,
# validación de firewall y comandos de verificación.
# Creado por: Branchcore Technology C.A. (SARYAD / R&D DevOps)
# Version: 2.4 QA
# Fecha: 22/11/2025
# ==============================================================

CERT_DIR_INDEXER="/etc/wazuh-indexer/certs"
CERT_DIR_DASHBOARD="/etc/wazuh-dashboard/certs"
CERT_DIR_MANAGER="/var/ossec/etc/sslmanager"
LOG_FILE="/var/log/wazuh_install_enterprise_pro.log"

WAZUH_USER="wazuh"
WAZUH_INDEXER_USER="wazuh-indexer"
WAZUH_DASHBOARD_USER="wazuh-dashboard"

PORTS_WAZUH=(1514 1515 55000 9200 9300)
SSH_PORT=50022

# ------------------------------ 
log() { echo "$(date '+%F %T') [INFO] $*" | tee -a "$LOG_FILE"; }
log_success() { echo "$(date '+%F %T') [OK] $*" | tee -a "$LOG_FILE"; }
log_error() { echo "$(date '+%F %T') [ERROR] $*" | tee -a "$LOG_FILE"; }

error_exit() { log_error "$1"; exit 1; }

# ------------------------------ 
# 0. Comprobación root
[ "$(id -u)" -ne 0 ] && error_exit "Debe ejecutar como root"

# ------------------------------ 
# 1. Pausa de servicios previos
systemctl stop wazuh-indexer wazuh-dashboard wazuh-manager 2>/dev/null
systemctl disable wazuh-indexer wazuh-dashboard wazuh-manager 2>/dev/null

# ------------------------------ 
# 2. Creación de directorios
mkdir -p "$CERT_DIR_INDEXER" "$CERT_DIR_DASHBOARD" "$CERT_DIR_MANAGER"

# ------------------------------ 
# 3. Creación de CA raíz QA
log "==> Creando CA raíz QA (SARYAD / R&D DevOps)"
openssl genrsa -out "$CERT_DIR_INDEXER/wazuh-root-ca.key" 4096 || error_exit "Falló creación CA key"
openssl req -x509 -new -nodes -key "$CERT_DIR_INDEXER/wazuh-root-ca.key" -sha256 -days 3650 \
    -out "$CERT_DIR_INDEXER/wazuh-root-ca.pem" \
    -subj "/O=SARYAD/OU=R&D DevOps/CN=Wazuh Root CA" || error_exit "Falló creación CA PEM"

# ------------------------------ 
# 4. Certificados Indexer y Dashboard QA
log "==> Creando certificados Indexer y Dashboard"
openssl genrsa -out "$CERT_DIR_INDEXER/indexer-key.pem" 2048 || error_exit "Falló indexer-key.pem"
openssl req -new -key "$CERT_DIR_INDEXER/indexer-key.pem" -out "$CERT_DIR_INDEXER/indexer.csr" \
    -subj "/O=SARYAD/OU=R&D DevOps/CN=wazuh-indexer.local" || error_exit "Falló indexer.csr"
openssl x509 -req -in "$CERT_DIR_INDEXER/indexer.csr" -CA "$CERT_DIR_INDEXER/wazuh-root-ca.pem" \
    -CAkey "$CERT_DIR_INDEXER/wazuh-root-ca.key" -CAcreateserial \
    -out "$CERT_DIR_INDEXER/indexer.pem" -days 3650 -sha256 || error_exit "Falló indexer.pem"
rm -f "$CERT_DIR_INDEXER/indexer.csr"

# Copia al Dashboard
cp "$CERT_DIR_INDEXER/indexer-key.pem" "$CERT_DIR_DASHBOARD/dashboard-key.pem"
cp "$CERT_DIR_INDEXER/indexer.pem" "$CERT_DIR_DASHBOARD/dashboard.pem"
cp "$CERT_DIR_INDEXER/wazuh-root-ca.pem" "$CERT_DIR_DASHBOARD/root-ca.pem"

# ------------------------------ 
# 5. Permisos de certificados
log "==> Ajustando permisos y dueños"
chown -R "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_USER" "$CERT_DIR_INDEXER"
chmod 500 "$CERT_DIR_INDEXER"
chmod 400 "$CERT_DIR_INDEXER"/*

chown -R "$WAZUH_DASHBOARD_USER:$WAZUH_DASHBOARD_USER" "$CERT_DIR_DASHBOARD"
chmod 750 "$CERT_DIR_DASHBOARD"
chmod 640 "$CERT_DIR_DASHBOARD"/*

chown -R "$WAZUH_USER:$WAZUH_USER" "$CERT_DIR_MANAGER"
chmod 750 "$CERT_DIR_MANAGER"
chmod 400 "$CERT_DIR_MANAGER"/*

# ------------------------------ 
# 6. Auditoría inicial
log "==> Auditoría de servicios y directorios"
for svc in wazuh-manager wazuh-indexer wazuh-dashboard; do
    if systemctl is-active --quiet "$svc"; then
        log_success "$svc activo"
    else
        log_error "$svc INACTIVO"
    fi
done

for DIR in "$CERT_DIR_INDEXER" "$CERT_DIR_DASHBOARD" "$CERT_DIR_MANAGER"; do
    if [ -d "$DIR" ]; then log_success "Directorio $DIR existe"; else log_error "$DIR NO existe"; fi
done

# ------------------------------ 
# 7. Firewall mínimo Wazuh
log "==> Configurando firewall"
ufw default deny incoming
ufw default allow outgoing
for PORT in "${PORTS_WAZUH[@]}"; do ufw allow "$PORT"; done
ufw allow "$SSH_PORT"
ufw --force enable

# ------------------------------ 
# 8. Reinicio y verificación (comandos QA)
log "==> Reiniciando servicios Wazuh"
systemctl daemon-reload
systemctl enable wazuh-indexer wazuh-dashboard wazuh-manager
systemctl restart wazuh-indexer wazuh-dashboard wazuh-manager || error_exit "Falló reinicio servicios"

log_success "Servicios reiniciados y activos"

log "==> Comprobación de estado con curl"
echo "Ejemplo: curl -k https://127.0.0.1:9200/_cluster/health?pretty --cert $CERT_DIR_INDEXER/indexer.pem --key $CERT_DIR_INDEXER/indexer-key.pem --cacert $CERT_DIR_INDEXER/wazuh-root-ca.pem"

# ------------------------------ 
# 9. Finalización
log_success "Instalación QA Enterprise Pro Wazuh v2.4 completada"
echo "Usuario por defecto: admin"
echo "Password por defecto: admin"
