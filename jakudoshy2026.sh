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

# Carpeta de logs
LOG_DIR="$HOME/.jakudoshy"
LOG_FILE="$LOG_DIR/jaku.log"
mkdir -p "$LOG_DIR"

# Salir
e() {
 exit 0
}

# DNS Datos
DNS_DATOS=("200.55.128.130" "200.55.128.140" "200.55.128.230" "200.55.128.250")
# DNS WiFi
DNS_WIFI=("181.225.231.120" "181.225.231.110" "181.225.233.40" "181.225.233.30")

DOMINIO="8.8.8.8"
PUERTO=53  # Puerto a comprobar (DNS por defecto)

# Función limpiar procesos
clean_client() {
    pkill -f slipstream-client 2>/dev/null
    sleep 1
}

# ASCII banner
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

# Menu Tren 
s_l () {
   sl ; clear
}

# Menu Matrix
c_m () {
   timeout 5 cmatrix ; clear
} 

#menu de instalación Python
pkg_python () {
   clear 
   echo ""
   echo "" 
   echo -e "${R}OJO SI TE SALE ALGO COMO [Y/N...] SELECCIONE SIEMPRE (Y)${NC}"; sleep 2 && pkg install python-pip && pip install slipstream-client
}

#Menu de instalación slipstream
Menu_Slipc () {
   clear
   jaku_ascii
   echo -e "${M}══════════════════════════════════════════════════"
   echo -e "         Menu De Instalación Slipstream         "
   echo -e "══════════════════════════════════════════════════${NC}"
   echo ""
   echo -e "───────────────────"
   echo -e "1) Instalar ✅"
   echo -e "2) Salir ❌"
   echo -e "───────────────────"
   echo ""
   read -p "👉 Seleccione Una Opcion :" opcion
   case $opcion in
      1) pkg_python ;;
      2) bash 0 ;;
      *) echo -e "❌Opcion No Existe ❌" ;;
   esac
}

# Función Slipstream con logs y timeout mejorado
slipstream_c() {
    local dns_ip="$1"
    clean_client
    > "$LOG_FILE"
    echo -e "${DG}▶ Probando DNS: ${dns_ip}${NC}"
    timeout 10 ./slipstream-client --tcp-listen-port=5201 \
        --resolver="${dns_ip}:53" --domain="$DOMINIO" \
        --keep-alive-interval=600 --congestion-control=cubic \
        > >(tee -a "$LOG_FILE") 2>&1 &
    PID=$!

    # Esperar confirmación con contador
    for i in {1..7}; do
        echo -ne "${Y}⏳ Esperando confirmación... ($i/7)${NC}\r"
        if grep -q "Connection confirmed" "$LOG_FILE"; then
            echo -e "\n${G}✅ Conexión establecida con ${dns_ip}${NC}"
            wait $PID
            return 0
        fi
        if grep -q "Connection closed" "$LOG_FILE"; then
            echo -e "\n${R}❌ Conexión cerrada en ${dns_ip}${NC}"
            break
        fi
        sleep 1
    done

    clean_client
    echo -e "${R}❌ Falló conexión con ${dns_ip}${NC}"
    return 1
}

# Animación fija de conexión
animacion_hacker () {
    echo -ne "${DG}Iniciando Probador DNS...${NC}"
    for i in {1..5}; do 
        echo -ne "${DG}.${NC}"
        sleep 0.1
    done
    echo -e " ${DG}Probando...${NC}"
}

# Menú post-conexión
menu_post_conexion () {
    dns_usado=$1
    clear
    jaku_ascii
    echo -e "${DG}══════════════════════════════════════════════════${NC}"
    echo -e "${DG}        ☘️ Conexión Establecida Con Éxito ✅${NC}"
    echo -e "${DG}══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${DG}Conectado Usando : ${dns_usado}${NC}"
    echo ""
    echo -e "${R}Presiona Ctrl+C para cerrar túnel${NC}"

    while true; do 
        sleep 1
    done
}

# Conexión con lista de DNS mejorada
dns_connect () {
    local servers=("$@")
    local fallidos=0
    for dns_ip in "${servers[@]}"; do
        clear
        jaku_ascii
        echo -e "${DG}Iniciando prueba con DNS: ${dns_ip}${NC}"
        animacion_hacker

        if slipstream_c "$dns_ip"; then
            menu_post_conexion "DNS - $dns_ip"
            return
        else
            ((fallidos++))
        fi
    done

    clear
    echo -e "${R}❌ No se pudo establecer conexión con ninguno de los ${#servers[@]} DNS${NC}"
    echo -e "${R}Fallidos: $fallidos / ${#servers[@]}${NC}"
    sleep 2
    menu_reconexion "${servers[@]}"
}

# Menú de reconexión
menu_reconexion () {
    local servers=("$@")
    clear
    jaku_ascii
    echo -e "${R}Menu De Reconexión De Jakudoshy    ${NC}"
    echo ""
    echo -e "${DG}Script Versión : 1.1 ${NC}"
    echo ""
    echo -e "${NC}1) Reconectar ${D}(DNS)${NC}"
    echo -e "${NC}2) Salir ${NC}"
    echo ""
    read -p "➜ " reconect
    case $reconect in
        1) dns_connect "${servers[@]}" ;;
        2) exit 0 ;;
        *) echo -e "${R}❌ OPCIÓN INVÁLIDA ❌${NC}" ;;
    esac
}

# Verificación real del servidor (ping + puerto)
check_server() {
    local server="$1"
    local port="$PUERTO"
    if ping -c 2 -W 2 "$server" > /dev/null 2>&1; then
        if nc -z -w3 "$server" "$port" > /dev/null 2>&1; then
            echo -e "${DG}SERVER ACTIVO ✅${NC}"
        else
            echo -e "${R}SERVER INACTIVO ❌${NC}"
        fi
    else
        echo -e "${R}SERVER INACTIVO ❌${NC}"
    fi
}

# Menú de verificación inicial (sin 'Comprobando')
menu_verificacion () {
    clear
    jaku_ascii
    echo -e "${M}══════════════════════════════════════════════════${NC}"
    echo -e "${M}        Verificando estado de servidor${NC}"
    echo -e "${M}══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${D}Esto solo durará un momento...${NC}"
    echo ""
    sleep 2
}

# Mostrar verificación inicial
menu_verificacion

# Detectar red activa (universal)
detect_network () {
    if termux-wifi-connectioninfo 2>/dev/null | grep -q '"ssid"'; then
        echo "Wifi"
    else
        for iface in rmnet_data0 rmnet0 ccmni0 pdp0 eth0; do
            if ip addr show "$iface" 2>/dev/null | grep -q "inet "; then
                echo "Datos Móviles"
                return
            fi
        done
        echo "Desconocido"
    fi
}

# Menú principal en bucle infinito
while true; do
    clear
    NET=$(detect_network)
    DATA_MARK="○"
    WIFI_MARK="○"
    [[ "$NET" == "Datos Móviles" ]] && DATA_MARK="●"
    [[ "$NET" == "Wifi" ]] && WIFI_MARK="●"

    jaku_ascii
    echo -e "${DG}Estas Usando : $NET ✓${NC}        ${DG} Versión:1.1${NC}"
    echo ""
    # Estado real del servidor en el menú principal
    check_server "$DOMINIO"
    echo -e "───────────────────────────────────────────"
    echo -e "${NC}$DATA_MARK 1) Conectar Con Datos Móviles${D}(Red Etecsa)${NC}"
    echo -e "${NC}$WIFI_MARK 2) Conectar Con Wifi ${D}(Pública/Nauta)${NC}"
    echo -e "  3) Unirte a Mi Canal ${D}(Telegram)${NC}"
    echo -e "  4)${R} Instala Esto Si No No Te Servira${NC}"
    echo -e "${NC}  5) Salir${NC}"
    echo -e "───────────────────────────────────────────"
    read -p "Seleccione Una Opción ➜ " opcion
    case $opcion in 
        1) dns_connect "${DNS_DATOS[@]}" ;;
        2) dns_connect "${DNS_WIFI[@]}" ;;
        3) am start -a android.intent.action.VIEW -d "https://t.me/internetcubavpngratis" ;;
        4) Menu_Slipc ;; 
        5) exit 0 ;;
        *) echo -e "${R}❌ OPCIÓN INVÁLIDA ❌${NC}" ;;
    esac
done