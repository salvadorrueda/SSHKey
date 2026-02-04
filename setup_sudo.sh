#!/bin/bash

# Script per donar permisos de sudo sense contrasenya a l'usuari salvadorrueda

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funcions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Comprovar si s'executa com a root
if [ "$EUID" -ne 0 ]; then
  log_error "Aquest script s'ha d'executar amb sudo (root)."
  exit 1
fi

USER_NAME="salvadorrueda"
SUDOERS_FILE="/etc/sudoers.d/$USER_NAME"

log_info "Configurant permisos per a l'usuari: $USER_NAME"

# 2. Crear el fitxer de configuració de sudo
# Utilitzem un fitxer temporal per validar-lo primer
TEMP_FILE=$(mktemp)
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > "$TEMP_FILE"

# 3. Validar la configuració amb visudo
visudo -cf "$TEMP_FILE" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_info "Configuració vàlida. Aplicant canvis..."
    mv "$TEMP_FILE" "$SUDOERS_FILE"
    chmod 0440 "$SUDOERS_FILE"
    chown root:root "$SUDOERS_FILE"
    log_success "Permisos configurats correctament a $SUDOERS_FILE"
    log_info "Ara l'usuari '$USER_NAME' pot executar sudo sense contrasenya."
else
    log_error "La configuració generada no és vàlida. No s'ha aplicat cap canvi."
    rm "$TEMP_FILE"
    exit 1
fi

log_success "Procés finalitzat."
