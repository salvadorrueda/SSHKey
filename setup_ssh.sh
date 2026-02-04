#!/bin/bash

# Script per automatitzar la creació i desplegament de claus SSH

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

# 1. Comprovar si ja existeix una clau ED25519
SSH_FILE="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_FILE" ]; then
    log_warn "Ja tens una clau SSH a $SSH_FILE."
    read -p "Vols sobreescriure-la? (s/N): " choice
    if [[ ! "$choice" =~ ^[sS]$ ]]; then
        log_info "Operació cancel·lada. Reutilitzant la clau existent."
    else
        log_info "Generant una nova clau..."
        rm "$SSH_FILE" "$SSH_FILE.pub"
    fi
fi

if [ ! -f "$SSH_FILE" ]; then
    # 2. Demanar comentari (email)
    read -p "Introdueix un comentari per la clau (ex. el teu correu): " COMMENT
    
    # 3. Generar la clau
    log_info "Generant clau ED25519..."
    ssh-keygen -t ed25519 -C "$COMMENT" -f "$SSH_FILE" -N ""
    log_success "Clau generada correctament a $SSH_FILE"
fi

# 4. Desplegament
read -p "Vols copiar la clau a un servidor remot? (S/n): " copy_choice
if [[ ! "$copy_choice" =~ ^[nN]$ ]]; then
    read -p "Introdueix l'usuari i host remot (ex: usuari@192.168.1.10): " REMOTE_HOST
    
    if [ -z "$REMOTE_HOST" ]; then
        log_error "No s'ha especificat cap host remot."
    else
        log_info "Copiant la clau a $REMOTE_HOST..."
        ssh-copy-id -i "$SSH_FILE.pub" "$REMOTE_HOST"
        
        if [ $? -eq 0 ]; then
            log_success "Clau copiada correctament a $REMOTE_HOST"
            log_info "Ara pots provar de connectar-te amb: ssh $REMOTE_HOST"
        else
            log_error "Hi ha hagut un error copiant la clau."
        fi
    fi
fi

log_success "Procés finalitzat."
