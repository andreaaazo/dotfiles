#!/bin/bash

# ==========================================
# CONFIGURAZIONE COLORI
# ==========================================
C="\033[1;36m"  # Ciano
G="\033[1;32m"  # Verde
Y="\033[1;33m"  # Giallo
B="\033[1;34m"  # Blu
W="\033[1;37m"  # Bianco
Z="\033[0m"     # Reset
R="\033[1;31m"  # Rosso
GR="\033[1;30m" # Grigio

# Intestazione
echo -e "\n${C} ⚡ HYPRLAND SYSTEM INTERNALS ⚡ ${Z}"
echo -e "${C}────────────────────────────────${Z}"

# ==========================================
# [ 1. SEZIONE CPU ]
# ==========================================
# Calcolo carico CPU (compatibile con vari output di top)
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

# Conteggio Processi
PR_TOT=$(ps -e --no-headers | wc -l)
RUN_LIST=$(ps -axo state,comm | awk '$1=="R" {print $2}' | sort | uniq | tr "\n" " ")
RUN_COUNT=$(echo "$RUN_LIST" | wc -w)
SLEEP_COUNT=$((PR_TOT - RUN_COUNT))

echo -e "${G}[ CPU ]${Z}"
echo -e "  Load: ${Y}${CPU_LOAD}${Z} | Tot: ${W}${PR_TOT}${Z} (Bg: ${W}${SLEEP_COUNT}${Z})"
echo -e "  Active Now [${Y}${RUN_COUNT}${Z}]: ${R}${RUN_LIST}${Z}"

# Top App CPU (> 0.5%)
ps -axo %cpu,comm --no-headers | \
awk '{a[$2]+=$1} END {for (i in a) if(a[i]>0.5) print a[i], i}' | \
sort -rn | head -5 | \
awk -v B="$B" -v Y="$Y" -v Z="$Z" '{printf " " B "•" Z " %-14s " Y "%s" Z "\n", $2, $1"%"}'

# ==========================================
# [ 2. SEZIONE RAM ]
# ==========================================
echo -e "\n${G}[ RAM ]${Z}"
free -h | awk -v Y="$Y" -v Z="$Z" '/Mem:/ {printf "  Use: " Y "%s" Z " / %s\n", $3, $2}'

# Top App RAM
ps -axo rss,comm --no-headers | \
awk '{a[$2]+=$1} END {for (i in a) print a[i], i}' | \
sort -rn | head -5 | \
awk -v B="$B" -v Y="$Y" -v Z="$Z" '{printf " " B "•" Z " %-14s " Y "%d MB" Z "\n", $2, $1/1024}'

# ==========================================
# [ 3. SEZIONE GPU ]
# ==========================================
echo -e "\n${G}[ GPU ]${Z}"

if command -v nvidia-smi &> /dev/null; then
    # NVIDIA
    INFO=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used --format=csv,noheader,nounits)
    U=$(echo "$INFO" | cut -d, -f1)
    T=$(echo "$INFO" | cut -d, -f2)
    M=$(echo "$INFO" | cut -d, -f3)
    
    echo -e "  Load: ${Y}$U%${Z} | Temp: ${Y}$T°C${Z} | VRAM: ${Y}${M}MiB${Z}"
    
    # Top App GPU Nvidia
    nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader,nounits | \
    awk -F, '{split($1, a, "/"); name = a[length(a)]; split(name, b, " "); clean = b[1]; arr[clean] += $2} END {for (i in arr) print arr[i], i}' | \
    sort -rn | head -3 | \
    awk -v B="$B" -v Y="$Y" -v Z="$Z" '{printf " " B "•" Z " %-14s " Y "%s MiB" Z "\n", $2, $1}'

elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
    # AMD (Metodo sysfs standard)
    AL=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
    echo -e "  AMD Load: ${Y}$AL%${Z}"
else
    echo -e "  GPU info not available"
fi

# ==========================================
# [ 4. SEZIONE SYSTEM SERVICES ]
# ==========================================
echo -e "\n${G}[ SERVICES ]${Z}"

SVC_RUN=$(systemctl list-units --type=service --state=running --no-legend --no-pager | wc -l)
SVC_FAIL=$(systemctl list-units --type=service --state=failed --no-legend --no-pager | wc -l)
# Lista servizi pulita (rimuove .service)
SVC_LIST=$(systemctl list-units --type=service --state=running --no-legend --no-pager --plain | awk '{print $1}' | sed "s/\.service//g" | sort | tr "\n" " ")

if [ "$SVC_FAIL" -gt 0 ]; then
    FAIL_LIST=$(systemctl list-units --type=service --state=failed --no-legend --no-pager --plain | awk '{print $1}' | sed "s/\.service//g" | tr "\n" " ")
    echo -e "  State: ${Y}${SVC_RUN} Active${Z} | ${R}⚠ ${SVC_FAIL} FAILED${Z}"
    echo -e "  ${R}Failed -> ${FAIL_LIST}${Z}"
else
    echo -e "  State: ${Y}${SVC_RUN} Active${Z} | ${G}✓ System Healthy${Z}"
fi

echo -e "${GR}  (Active Daemons List):${Z}"
# Formattazione lista con a capo automatico
echo "$SVC_LIST" | fold -s -w 70 | awk -v W="$W" -v Z="$Z" '{print "  " W $0 Z}'
