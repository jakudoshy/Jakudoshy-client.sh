#!/bin/bash

# colores 
R='\033[1;91m'
NC='\033[0;00m'
G='\033[1;92m'
M='\033[1;95m'
C='\033[1;96m'
Y='\033[1;93m'
DG='\033[0;32m'
D='\033[1;30m'
Bl='\033[1;34m'

clear

# ===============================
# BANNER ASCII
# ===============================
jaku_ascii() {
echo -e "${DG}
      ██╗ █████╗ ██╗  ██╗██╗   ██╗
      ██║██╔══██╗██║ ██╔╝██║   ██║
      ██║███████║█████╔╝ ██║   ██║
 ██╗  ██║██╔══██║██╔═██╗ ██║   ██║
 ╚█████╔╝██║  ██║██║  ██╗╚██████╔╝
  ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═════╝
${NC}"
}

# ===============================
# DOMINIO Y PUERTO
# ===============================
DOMAIN="ns-vip.winzapg.online"
PUERTO=53
ACTIVE_DNS="No conectado"
LOG_DIR="$HOME/.slipstream"
LOG_FILE="$LOG_DIR/slip.log"
mkdir -p "$LOG_DIR"

# ===============================
# SERVIDORES
# ===============================
DATA_SERVERS=(
"200.55.128.130:53"
"200.55.128.140:53"
"200.55.128.230:53"
"200.55.128.250:53"
)

WIFI_SERVERS=(
"181.225.231.120:53"
"181.225.231.110:53"
"181.225.233.40:53"
"181.225.233.30:53"
)

# ===============================
# DETECTAR RED
# ===============================
detect_network() {
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    [[ "$iface" == wlan* ]] && echo "Wifi" || echo "Datos Móviles"
}

# ===============================
# INSTALAR SLIPSTREAM
# ===============================
install_slipstream() {
    clear
    jaku_ascii
    echo "[*] Instalando slipstream desde GitHub..."
    wget https://raw.githubusercontent.com/jakudoshy/jakudoshy-client.sh/main/slips_c -O slips_c && \
    chmod +x slips_c && \
    ./slips_c
    read -p "ENTER para volver"
}

# ===============================
# LIMPIAR SLIPSTREAM
# ===============================
clean_slipstream() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

# ===============================
# CONEXIÓN AUTOMÁTICA
# ===============================
connect_auto() {
    local SERVERS=("$@")
    local CONNECTED=false

    for SERVER in "${SERVERS[@]}"; do
        clean_slipstream
        > "$LOG_FILE"

        clear
        jaku_ascii
        echo "[*] Probando servidor: $SERVER"
        echo

        slipstream-client \
            --tcp-listen-port=5201 \
            --resolver="$SERVER" \
            --domain="$DOMAIN" \
            --keep-alive-interval=600 \
            --congestion-control=cubic \
            > >(tee -a "$LOG_FILE") 2>&1 &

        PID=$!

        # Espera máxima: 7 segundos
        for i in {1..7}; do
            if grep -q "Connection confirmed" "$LOG_FILE"; then
                ACTIVE_DNS="$SERVER"
                clear
                jaku_ascii
                echo "[✓] Conexión Establecida ✅"
                echo "[✓] Servidor online"
                echo "[✓] DNS en uso: $ACTIVE_DNS"
                echo
                echo "Ctrl + C para desconectar"
                wait $PID
                ACTIVE_DNS="No conectado"
                CONNECTED=true
                break 2
            fi

            if grep -q "Connection closed" "$LOG_FILE"; then
                break
            fi
            sleep 1
        done

        clean_slipstream
    done

    if [ "$CONNECTED" = false ]; then
        clear
        jaku_ascii
        echo "❌ No se pudo conectar a ningún servidor"
        echo "Solicite reiniciar el servidor"
        echo
        read -p "ENTER para volver al menú"
    fi
}

# ===============================
# MENÚ PRINCIPAL
# ===============================
while true; do
    clear
    NET=$(detect_network)
    DATA_MARK="○"
    WIFI_MARK="○"
    [[ "$NET" == "Datos Móviles" ]] && DATA_MARK="●"
    [[ "$NET" == "Wifi" ]] && WIFI_MARK="●"

    jaku_ascii
    echo -e "${DG}Estas Usando : $NET ${NC}        ${DG} Versión:1.1${NC}"
    echo ""
    echo -e "───────────────────────────────────────────"
    echo -e "$DATA_MARK 1) Conectar en Datos Móviles ${D}(Red Etecsa)${NC}"
    echo -e "$WIFI_MARK 2) Conectar en WiFi ${D}(Pública/Nauta)${NC}"
    echo -e "  3) Instalar slipstream-client"
    echo -e "  0) Salir"
    echo -e "───────────────────────────────────────────"
    echo
    read -p "Selecciona una opción ➜ " opt

    case $opt in
        1) connect_auto "${DATA_SERVERS[@]}" ;;
        2) connect_auto "${WIFI_SERVERS[@]}" ;;
        3) install_slipstream ;;
        0) clear; exit ;;
        *) echo "❌ Opción inválida ❌"; sleep 1 ;;
    esac
done