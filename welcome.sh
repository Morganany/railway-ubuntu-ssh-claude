#!/bin/bash
# Tampilan console saat login SSH (interaktif saja, sekali per sesi)
case $- in *i*) ;; *) return 0 2>/dev/null || exit 0 ;; esac
[ -n "$VPS_WELCOME_SHOWN" ] && return 0
export VPS_WELCOME_SHOWN=1

# Nama brand: dari /etc/vps-brand, atau dari env container (PID 1) kalau entrypoint ga nulis file itu
BRAND="$(cat /etc/vps-brand 2>/dev/null)"
[ -z "$BRAND" ] && BRAND="$(tr '\0' '\n' </proc/1/environ 2>/dev/null | sed -n 's/^BRAND_NAME=//p' | head -1)"
BRAND="${BRAND:-VPS System}"
C=$'\e[1;36m'; G=$'\e[0;90m'; W=$'\e[0;37m'; O=$'\e[1;32m'; R=$'\e[0m'

. /etc/os-release 2>/dev/null
cpu=$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^ +/,"",$2); print $2; exit}')
cores=$(nproc 2>/dev/null)
mem=$(free -h 2>/dev/null | awk '/Mem:/ {print $3 " / " $2}')
disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)
up=$(uptime -p 2>/dev/null | sed 's/^up //')

row() { printf "  ${C}%-8s${G}│${W} %s${R}\n" "$1" "$2"; }

echo
echo "  ${C}${BRAND}${R} ${G}·${R} ${W}Ubuntu Cloud Shell${R}"
echo "  ${G}────────────────────────────────────────${R}"
row "User"   "$(whoami) @ $(hostname)"
row "OS"     "${PRETTY_NAME:-Ubuntu}"
row "Kernel" "$(uname -r)"
row "Uptime" "${up:--}"
row "CPU"    "${cpu:--} (${cores:-?} cores)"
row "Memory" "${mem:--}"
row "Disk"   "${disk:--}"
row "IP"     "${ip:--}"
echo "  ${G}────────────────────────────────────────${R}"
echo "  ${O}● online${R}"
echo
