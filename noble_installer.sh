#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#   NOBLE INSTALLER - by keylordelrey
#   Ubuntu Noble PRoot Setup for Termux
# ============================================================

# ── WARNA ─────────────────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
O='\033[38;5;214m'
B='\033[0;34m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
GR='\033[0;90m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ── SIMBOL & ELEMEN ────────────────────────────────────────
OK="${G}✓${NC}"
FAIL="${R}✗${NC}"
LOAD="${C}◌${NC}"
DOT="${O}▸${NC}"
BAR_FILL="${G}█${NC}"
BAR_EMPTY="${DIM}▒${NC}"

# ── PROGRESS BAR ───────────────────────────────────────────
draw_bar() {
    local percent=$1
    local width=36
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    printf "${C}[${NC}"
    for ((i=0; i<filled; i++)); do printf "${BAR_FILL}"; done
    for ((i=0; i<empty; i++)); do printf "${BAR_EMPTY}"; done
    printf "${C}]${NC} ${O}%3d%%${NC}" "$percent"
}

# ── SPINNER ────────────────────────────────────────────────
spin() {
    local msg="$1"
    local delay=${2:-0.08}
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while :; do
        printf "\r  ${C}${frames[$i]}${NC}  ${msg}"
        i=$(( (i+1) % 10 ))
        sleep $delay
    done
}

start_spin() {
    SPIN_PID=""
    local msg="$1"
    local delay=${2:-0.08}
    spin "$msg" "$delay" &
    SPIN_PID=$!
}

stop_spin() {
    if [ -n "$SPIN_PID" ]; then
        kill $SPIN_PID 2>/dev/null
        wait $SPIN_PID 2>/dev/null
        SPIN_PID=""
    fi
    printf "\r%-60s\r" " "
}

# ── FUNGSI CETAK ──────────────────────────────────────────
step()    { echo -e "  ${DOT} ${BOLD}${1}${NC}"; }
ok()      { echo -e "  ${OK} ${DIM}${1}${NC}"; }
fail()    { echo -e "\n  ${FAIL} ${R}${1}${NC}\n"; exit 1; }
info()    { echo -e "  ${DIM}   ${1}${NC}"; }
warn()    { echo -e "  ${Y}⚠ ${1}${NC}"; }

section() {
    echo ""
    echo -e "  ${O}╔${NC}$(printf '%.0s═' {1..50})${O}╗${NC}"
    printf "  ${O}║${NC}  ${BOLD}${1}${NC}"
    printf '%.0s' {1..$(( 46 - ${#1} ))}
    echo -e "${O}║${NC}"
    echo -e "  ${O}╚${NC}$(printf '%.0s═' {1..50})${O}╝${NC}"
    echo ""
}

# ── BANNER ─────────────────────────────────────────────────
banner() {
    clear
    echo ""
    echo -e "  ${O}╭──────────────────────────────────────╮${NC}"
    echo -e "  ${O}│${NC}  ${M}███╗   ██╗${NC} ${C}██████╗ ██╗   ██╗${NC} ${G}██╗  ██╗${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}████╗  ██║${NC} ${C}██╔══██╗██║   ██║${NC} ${G}╚██╗██╔╝${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██╔██╗ ██║${NC} ${C}██████╔╝██║   ██║${NC} ${G} ╚███╔╝${NC}   ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██║╚██╗██║${NC} ${C}██╔══██╗██║   ██║${NC} ${G} ██╔██╗${NC}   ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██║ ╚████║${NC} ${C}██████╔╝╚██████╔╝${NC} ${G}██╔╝ ██╗${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}╚═╝  ╚═══╝${NC} ${C}╚═════╝  ╚═════╝${NC} ${G}╚═╝  ╚═╝${NC}  ${O}│${NC}"
    echo -e "  ${O}╰──────────────────────────────────────╯${NC}"
    echo ""
    echo -e "  ${DIM}   Ubuntu Noble PRoot Installer for Termux${NC}"
    echo -e "  ${DIM}   by ${O}keylordelrey${NC}"
    echo ""
}

# ── TABEL VERIFIKASI ───────────────────────────────────────
check_table() {
    local label="$1"
    local value="$2"
    printf "  ${O}│${NC}  ${W}%-20s${NC}  ${G}→${NC}  ${C}%s${NC}" "$label" "$value"
    printf '%.0s ' {1..$(( 40 - ${#value} ))}
    echo -e "${O}│${NC}"
}

# ============================================================
#   MULAI
# ============================================================

banner

section "PERSIAPAN SISTEM"

step "Membersihkan instalasi lama..."
rm -rf ~/ubuntu-noble ~/login_noble.sh 2>/dev/null
ok "Direktori lama dihapus"

step "Update & upgrade Termux packages..."
echo ""
start_spin "Updating packages" 0.1
pkg update -y && pkg upgrade -y
stop_spin
ok "Packages updated"

step "Install dependensi: wget proot tar curl..."
echo ""
start_spin "Installing dependencies" 0.1
pkg install -y wget proot tar curl
stop_spin
echo ""

if ! command -v proot &>/dev/null; then
    fail "proot gagal terinstall! Coba manual: pkg install proot"
fi
ok "Semua dependensi OK  |  proot: $(command -v proot)"

# ============================================================

section "DETEKSI ARSITEKTUR"

ARCH=$(dpkg --print-architecture 2>/dev/null || uname -m)
case "$ARCH" in
    aarch64|arm64) ARCH_NAME="arm64" ;;
    armv7l|armhf)  ARCH_NAME="armhf" ;;
    x86_64)        ARCH_NAME="amd64" ;;
    *)             ARCH_NAME="arm64"; warn "Arsitektur tidak dikenal ($ARCH), default arm64" ;;
esac

echo ""
echo -e "  ${O}┌─${NC} ARCHITECTURE ${O}────────────────────────────┐${NC}"
echo -e "  ${O}│${NC}  ${GR}Detected:${NC}   ${W}${ARCH}${NC}"
echo -e "  ${O}│${NC}  ${GR}Target:${NC}     ${G}${ARCH_NAME}${NC}"
echo -e "  ${O}└──────────────────────────────────────────┘${NC}"
echo ""

FOLDER="ubuntu-noble"
mkdir -p ~/$FOLDER
cd ~/$FOLDER

# ============================================================

section "DOWNLOAD UBUNTU NOBLE"

step "Mencari link terbaru dari server Ubuntu..."
echo ""

URL=$(curl -s https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/ \
    | grep -oP "ubuntu-base-[0-9.]+-base-${ARCH_NAME}\.tar\.gz" | head -n 1)

if [ -z "$URL" ]; then
    warn "Auto-detect gagal, pakai link fallback..."
    FULL_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/ubuntu-base-24.04-base-${ARCH_NAME}.tar.gz"
else
    FULL_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$URL"
fi

info "URL: ${FULL_URL}"
echo ""

step "Downloading rootfs..."
echo ""

wget --no-check-certificate -q --progress=bar:force:noscroll \
    "$FULL_URL" -O rootfs.tar.gz 2>&1 | \
while IFS= read -r line; do
    if [[ $line =~ ([0-9]+)% ]]; then
        percent="${BASH_REMATCH[1]}"
        printf "\r  ${C} Downloading...${NC}  "
        draw_bar "$percent"
    fi
done

echo ""
echo ""

if [ ! -s rootfs.tar.gz ]; then
    fail "Download gagal! Cek koneksi internet atau coba lagi."
fi
ok "Download selesai: $(du -sh rootfs.tar.gz | cut -f1)"

# ============================================================

section "EKSTRAKSI ROOTFS"

step "Mengekstrak rootfs..."
echo ""

start_spin "Extracting rootfs" 0.08
proot --link2symlink tar -xf rootfs.tar.gz --exclude='dev'
stop_spin

ok "Ekstraksi selesai"

# ============================================================

section "KONFIGURASI SISTEM"

step "Membuat folder sistem dasar..."
mkdir -p dev proc sys tmp home root etc
ok "Folder dibuat"

step "Setup DNS resolver..."
echo "nameserver 8.8.8.8"  > etc/resolv.conf
echo "nameserver 1.1.1.1" >> etc/resolv.conf
ok "DNS: 8.8.8.8 + 1.1.1.1"

# ============================================================

section "MEMBUAT SCRIPT LOGIN"

step "Generate ~/login_noble.sh..."

cat > ~/login_noble.sh << 'INNER'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ubuntu-noble
unset LD_PRELOAD
exec proot \
    --link2symlink \
    -0 \
    -r . \
    -b /dev \
    -b /proc \
    -b /sys \
    -b /sdcard \
    -b /data/data/com.termux/files/usr/tmp:/tmp \
    -w /root \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    LANG=C.UTF-8 \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash --login
INNER

chmod +x ~/login_noble.sh
ok "login_noble.sh siap"

step "Tambah alias 'noble' ke shell config..."
for RC in ~/.bashrc ~/.zshrc; do
    [ -f "$RC" ] || continue
    grep -q "alias noble" "$RC" || echo "alias noble='~/login_noble.sh'" >> "$RC"
done
[ -f ~/.bashrc ] || echo "alias noble='~/login_noble.sh'" > ~/.bashrc
ok "Alias 'noble' ditambahkan"

# ============================================================

section "SETUP INSIDE UBUNTU (AUTO)"

step "Menulis setup_ubuntu.sh ke dalam rootfs..."

cat > ~/ubuntu-noble/root/setup_ubuntu.sh << 'UBSCRIPT'
#!/bin/bash

# ── WARNA ────────────────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
O='\033[38;5;214m'
B='\033[0;34m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
GR='\033[0;90m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

OK="${G}✓${NC}"
FAIL="${R}✗${NC}"
LOAD="${C}◌${NC}"
DOT="${O}▸${NC}"
BAR_FILL="${G}█${NC}"
BAR_EMPTY="${DIM}▒${NC}"

draw_bar() {
    local percent=$1
    local width=36
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    printf "${C}[${NC}"
    for ((i=0; i<filled; i++)); do printf "${BAR_FILL}"; done
    for ((i=0; i<empty; i++)); do printf "${BAR_EMPTY}"; done
    printf "${C}]${NC} ${O}%3d%%${NC}" "$percent"
}

spin() {
    local msg="$1"
    local delay=${2:-0.08}
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while :; do
        printf "\r  ${C}${frames[$i]}${NC}  ${msg}"
        i=$(( (i+1) % 10 ))
        sleep $delay
    done
}

start_spin() {
    SPIN_PID=""
    local msg="$1"
    local delay=${2:-0.08}
    spin "$msg" "$delay" &
    SPIN_PID=$!
}

stop_spin() {
    if [ -n "$SPIN_PID" ]; then
        kill $SPIN_PID 2>/dev/null
        wait $SPIN_PID 2>/dev/null
        SPIN_PID=""
    fi
    printf "\r%-60s\r" " "
}

step_u() { echo -e "  ${DOT} ${BOLD}${1}${NC}"; }
ok_u()   { echo -e "  ${OK} ${DIM}${1}${NC}"; }
fail_u() { echo -e "\n  ${FAIL} ${R}ERROR: ${1}${NC}\n"; exit 1; }

section_u() {
    echo ""
    echo -e "  ${O}╔${NC}$(printf '%.0s═' {1..50})${O}╗${NC}"
    printf "  ${O}║${NC}  ${BOLD}${1}${NC}"
    printf '%.0s' {1..$(( 46 - ${#1} ))}
    echo -e "${O}║${NC}"
    echo -e "  ${O}╚${NC}$(printf '%.0s═' {1..50})${O}╝${NC}"
    echo ""
}

banner_u() {
    clear
    echo ""
    echo -e "  ${O}╭──────────────────────────────────────╮${NC}"
    echo -e "  ${O}│${NC}  ${M}██╗   ██╗${NC} ${C}██████╗ ██╗   ██╗${NC} ${G}██╗  ██╗${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██║   ██║${NC} ${C}██╔══██╗██║   ██║${NC} ${G}╚██╗██╔╝${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██║   ██║${NC} ${C}██████╔╝██║   ██║${NC} ${G} ╚███╔╝${NC}   ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}██║   ██║${NC} ${C}██╔══██╗██║   ██║${NC} ${G} ██╔██╗${NC}   ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M}╚██████╔╝${NC} ${C}██████╔╝╚██████╔╝${NC} ${G}██╔╝ ██╗${NC}  ${O}│${NC}"
    echo -e "  ${O}│${NC}  ${M} ╚═════╝ ${NC} ${C}╚═════╝  ╚═════╝${NC} ${G}╚═╝  ╚═╝${NC}  ${O}│${NC}"
    echo -e "  ${O}╰──────────────────────────────────────╯${NC}"
    echo ""
    echo -e "  ${DIM}   Post-Install Setup${NC}"
    echo -e "  ${DIM}   Node 22 + PNPM + Python 3.11 + Tools${NC}"
    echo ""
}

# ── BOX VERIFIKASI ─────────────────────────────────────────
check_table() {
    local label="$1"
    local value="$2"
    printf "  ${O}│${NC}  ${W}%-20s${NC}  ${G}→${NC}  ${C}%s${NC}" "$label" "$value"
    printf '%.0s ' {1..$(( 40 - ${#value} ))}
    echo -e "${O}│${NC}"
}

banner_u

# ── BASE UPDATE ───────────────────────────────────────────
section_u "UPDATE & BASE PACKAGES"

step_u "apt update & upgrade..."
echo ""
start_spin "Updating apt" 0.1
apt update -y && apt upgrade -y
stop_spin
ok_u "Sistem up-to-date"

step_u "Install base tools..."
echo ""
start_spin "Installing base tools" 0.1
apt install -y curl git gh nano htop unzip zip neofetch \
    software-properties-common
stop_spin
ok_u "curl git gh nano htop unzip zip neofetch — siap"

# ── NODE.JS 22 ────────────────────────────────────────────
section_u "NODE.JS 22"

step_u "Download NodeSource setup script..."
curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
    || fail_u "Gagal download NodeSource"
ok_u "Script didownload"

step_u "Jalankan NodeSource setup..."
echo ""
start_spin "Configuring Node.js 22 repo" 0.1
bash /tmp/nodesource_setup.sh
stop_spin
ok_u "Repo Node.js 22 aktif"

step_u "Install nodejs..."
echo ""
start_spin "Installing Node.js" 0.1
apt install -y nodejs
stop_spin
ok_u "Node.js: $(node -v)  |  NPM: $(npm -v)"

# ── PNPM ─────────────────────────────────────────────────
section_u "PNPM"

step_u "Install PNPM via npm..."
echo ""
start_spin "Installing PNPM" 0.1
npm install -g pnpm
stop_spin
ok_u "PNPM: $(pnpm -v)"

step_u "Setup PNPM global bin path..."
grep -q "PNPM_HOME" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'PNPMENV'

# --- PNPM ---
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
PNPMENV
ok_u "PNPM_HOME ditambahkan ke PATH"

# ── PYTHON 3.11 ───────────────────────────────────────────
section_u "PYTHON 3.11"

step_u "Tambah deadsnakes PPA..."
echo ""
start_spin "Adding deadsnakes PPA" 0.1
add-apt-repository ppa:deadsnakes/ppa -y && apt update -y
stop_spin
ok_u "PPA deadsnakes aktif"

step_u "Install Python 3.11 + venv + dev..."
echo ""
start_spin "Installing Python 3.11" 0.1
apt install -y python3.11 python3.11-venv python3.11-dev
stop_spin
ok_u "Python 3.11 terinstall"

step_u "Set default python3 & python..."
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
update-alternatives --install /usr/bin/python  python  /usr/bin/python3.11 1
ok_u "python → python3.11"

step_u "Install pip..."
echo ""
start_spin "Installing pip" 0.1
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11
stop_spin
ok_u "pip: $(python3.11 -m pip --version | cut -d' ' -f1-2)"

# ── VIRTUALENV ────────────────────────────────────────────
section_u "VIRTUAL ENVIRONMENT"

step_u "Buat venv di ~/.myenv..."
echo ""
start_spin "Creating virtual environment" 0.1
python3.11 -m venv ~/.myenv
stop_spin
ok_u "~/.myenv siap"

step_u "Tambah alias on/off ke ~/.bashrc..."
grep -q "alias on=" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'BRCALIAS'

# --- Noble Python Venv ---
alias on='source ~/.myenv/bin/activate'
alias off='deactivate'
alias python='python3'
BRCALIAS
ok_u "Alias 'on' dan 'off' aktif"

# ── VERIFIKASI AKHIR ──────────────────────────────────────
section_u "VERIFIKASI INSTALASI"

echo ""
echo -e "  ${O}┌──────────────────────────────────────────┐${NC}"
echo -e "  ${O}│${NC}  ${BOLD}${W}INSTALLATION SUMMARY${NC}"
echo -e "  ${O}├──────────────────────────────────────────┤${NC}"

check_table "Node.js"  "$(node -v 2>/dev/null || echo '✘ not found')"
check_table "NPM"      "$(npm -v 2>/dev/null || echo '✘ not found')"
check_table "PNPM"     "$(pnpm -v 2>/dev/null || echo '✘ not found')"
check_table "Python"   "$(python3.11 --version 2>/dev/null || echo '✘ not found')"
check_table "pip"      "$(python3.11 -m pip --version 2>/dev/null | cut -d' ' -f1-2 || echo '✘ not found')"
check_table "git"      "$(git --version 2>/dev/null | cut -d' ' -f3 || echo '✘ not found')"
check_table "gh"       "$(gh --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo '✘ not found')"
check_table "htop"     "$(htop --version 2>/dev/null | head -1 | cut -d' ' -f2 || echo '✘ not found')"
check_table "neofetch" "$(neofetch --version 2>/dev/null || echo 'installed')"

echo -e "  ${O}└──────────────────────────────────────────┘${NC}"
echo ""
echo -e "  ${G}✓ Ubuntu Noble siap dipakai!${NC}"
echo ""
echo -e "  ${DIM}   Tip:${NC}"
echo -e "  ${DIM}   › 'on'             → aktifkan Python venv${NC}"
echo -e "  ${DIM}   › 'off'            → keluar venv${NC}"
echo -e "  ${DIM}   › 'neofetch'       → lihat info sistem${NC}"
echo -e "  ${DIM}   › source ~/.bashrc → reload alias & PATH${NC}"
echo ""
UBSCRIPT

chmod +x ~/ubuntu-noble/root/setup_ubuntu.sh
ok "setup_ubuntu.sh ditulis ke rootfs"

# ============================================================

section "SELESAI"

echo ""
echo -e "  ${O}╭──────────────────────────────────────────╮${NC}"
echo -e "  ${O}│${NC}  ${G}✓ INSTALLATION COMPLETE${NC}"
echo -e "  ${O}├──────────────────────────────────────────┤${NC}"
echo -e "  ${O}│${NC}"
echo -e "  ${O}│${NC}  ${GR}1.${NC}  Reload shell  ${DIM}→${NC}  ${C}source ~/.bashrc${NC}"
echo -e "  ${O}│${NC}"
echo -e "  ${O}│${NC}  ${GR}2.${NC}  Login Ubuntu ${DIM}→${NC}  ${C}noble${NC}"
echo -e "  ${O}│${NC}"
echo -e "  ${O}│${NC}  ${GR}3.${NC}  Setup tools  ${DIM}→${NC}  ${C}bash /root/setup_ubuntu.sh${NC}"
echo -e "  ${O}│${NC}"
echo -e "  ${O}╰──────────────────────────────────────────╯${NC}"
echo ""