#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#   NOBLE INSTALLER - by keylordelrey
#   Ubuntu Noble PRoot Setup for Termux
# ============================================================

# --- WARNA ---
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
O='\033[38;5;214m'   # Orange
B='\033[0;34m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# --- SIMBOL ---
OK="${G}✔${NC}"
FAIL="${R}✘${NC}"
ARROW="${O}›${NC}"
SPARK="${O}◆${NC}"
LINE="${DIM}────────────────────────────────────────────${NC}"

# --- FUNGSI ---
banner() {
    clear
    echo ""
    echo -e "  ${O}${BOLD}"
    echo -e "  ███╗   ██╗ ██████╗ ██████╗ ██╗     ███████╗"
    echo -e "  ████╗  ██║██╔═══██╗██╔══██╗██║     ██╔════╝"
    echo -e "  ██╔██╗ ██║██║   ██║██████╔╝██║     █████╗  "
    echo -e "  ██║╚██╗██║██║   ██║██╔══██╗██║     ██╔══╝  "
    echo -e "  ██║ ╚████║╚██████╔╝██████╔╝███████╗███████╗"
    echo -e "  ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝${NC}"
    echo ""
    echo -e "  ${DIM}Ubuntu Noble PRoot Installer for Termux${NC}"
    echo -e "  ${DIM}by ${O}keylordelrey${NC}"
    echo ""
    echo -e "  ${LINE}"
    echo ""
}

step()    { echo -e "  ${ARROW} ${BOLD}${1}${NC}"; }
ok()      { echo -e "  ${OK} ${DIM}${1}${NC}"; }
fail()    { echo -e "\n  ${FAIL} ${R}${1}${NC}\n"; exit 1; }
info()    { echo -e "  ${DIM}     ${1}${NC}"; }
warn()    { echo -e "  ${Y}⚠  ${1}${NC}"; }

section() {
    echo ""
    echo -e "  ${O}${BOLD}  ${1}${NC}"
    echo -e "  ${LINE}"
    echo ""
}

run_spin() {
    local msg=$1
    shift
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    "$@" > /dev/null 2>&1 &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
        printf "\r  ${O}${frames[$i]}${NC}  ${DIM}${msg}...${NC}"
        i=$(( (i+1) % 10 ))
        sleep 0.12
    done
    printf "\r%-60s\r" " "
    wait $pid
    return $?
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
pkg update -y && pkg upgrade -y
echo ""
ok "Packages updated"

step "Install dependensi: wget proot tar curl..."
echo ""
pkg install -y wget proot tar curl
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

echo -e "  ${SPARK} Arsitektur terdeteksi: ${O}${BOLD}${ARCH}${NC}  ${DIM}→ target: ${ARCH_NAME}${NC}"

FOLDER="ubuntu-noble"
mkdir -p ~/$FOLDER
cd ~/$FOLDER

# ============================================================

section "DOWNLOAD UBUNTU NOBLE"

step "Mencari link terbaru dari server Ubuntu..."
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

step "Downloading rootfs (~29MB)..."
echo ""
wget --no-check-certificate --progress=bar:force \
    "$FULL_URL" -O rootfs.tar.gz 2>&1
echo ""

if [ ! -s rootfs.tar.gz ]; then
    fail "Download gagal! Cek koneksi internet atau coba lagi."
fi
ok "Download selesai: $(du -sh rootfs.tar.gz | cut -f1)"

# ============================================================

section "EKSTRAKSI ROOTFS"

step "Mengekstrak rootfs..."
echo ""
run_spin "Extracting Ubuntu Noble rootfs" \
    proot --link2symlink tar -xf rootfs.tar.gz --exclude='dev'
echo ""
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

# ============================================================
#   UBUNTU NOBLE - POST INSTALL SETUP
#   Node.js 22 + PNPM + Python 3.11 + Git + GH CLI + Tools
# ============================================================

R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
O='\033[38;5;214m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

OK="${G}✔${NC}"
FAIL="${R}✘${NC}"
ARROW="${O}›${NC}"
LINE="${DIM}────────────────────────────────────────────${NC}"

banner_u() {
    clear
    echo ""
    echo -e "  ${O}${BOLD}"
    echo -e "  ██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗"
    echo -e "  ██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║"
    echo -e "  ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║"
    echo -e "  ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║"
    echo -e "  ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝"
    echo -e "   ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝${NC}"
    echo ""
    echo -e "  ${DIM}Noble Post-Install — Node 22 + PNPM + Python 3.11 + Tools${NC}"
    echo -e "  ${LINE}"
    echo ""
}

section_u() {
    echo ""
    echo -e "  ${O}${BOLD}  ${1}${NC}"
    echo -e "  ${LINE}"
    echo ""
}

step_u() { echo -e "  ${ARROW} ${BOLD}${1}${NC}"; }
ok_u()   { echo -e "  ${OK} ${DIM}${1}${NC}"; }
fail_u() { echo -e "\n  ${FAIL} ${R}ERROR: ${1}${NC}\n"; exit 1; }

banner_u

# ── BASE UPDATE ───────────────────────────────────────────
section_u "UPDATE & BASE PACKAGES"

step_u "apt update & upgrade..."
apt update -y && apt upgrade -y || fail_u "apt update gagal"
ok_u "Sistem up-to-date"

step_u "Install base tools..."
apt install -y curl git gh nano htop unzip zip neofetch \
    software-properties-common || fail_u "Install base tools gagal"
ok_u "curl git gh nano htop unzip zip neofetch — siap"

# ── NODE.JS 22 ────────────────────────────────────────────
section_u "NODE.JS 22"

step_u "Download NodeSource setup script..."
curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
    || fail_u "Gagal download NodeSource"
ok_u "Script didownload"

step_u "Jalankan NodeSource setup..."
bash /tmp/nodesource_setup.sh || fail_u "NodeSource setup gagal"
ok_u "Repo Node.js 22 aktif"

step_u "Install nodejs..."
apt install -y nodejs || fail_u "Install nodejs gagal"
ok_u "Node.js: $(node -v)  |  NPM: $(npm -v)"

# ── PNPM ─────────────────────────────────────────────────
section_u "PNPM"

step_u "Install PNPM via npm..."
npm install -g pnpm || fail_u "Install pnpm gagal"
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
add-apt-repository ppa:deadsnakes/ppa -y && apt update -y \
    || fail_u "Gagal tambah PPA"
ok_u "PPA deadsnakes aktif"

step_u "Install Python 3.11 + venv + dev..."
apt install -y python3.11 python3.11-venv python3.11-dev \
    || fail_u "Install Python gagal"
ok_u "Python 3.11 terinstall"

step_u "Set default python3 & python..."
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
update-alternatives --install /usr/bin/python  python  /usr/bin/python3.11 1
ok_u "python → python3.11"

step_u "Install pip..."
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 \
    || fail_u "Install pip gagal"
ok_u "pip: $(python3.11 -m pip --version | cut -d' ' -f1-2)"

# ── VIRTUALENV ────────────────────────────────────────────
section_u "VIRTUAL ENVIRONMENT"

step_u "Buat venv di ~/.myenv..."
python3.11 -m venv ~/.myenv || fail_u "Buat venv gagal"
ok_u "~/.myenv siap"

step_u "Tambah alias on/off ke ~/.bashrc..."
grep -q "alias on=" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'BRCALIAS'

# --- Noble Python Venv ---
alias on='source ~/.myenv/bin/activate'
alias off='deactivate'
alias python='python3'
BRCALIAS
ok_u "Alias 'on' dan 'off' aktif"

# ── VERIFIKASI ────────────────────────────────────────────
section_u "VERIFIKASI INSTALASI"

pad() { printf "  ${O}  %-10s${NC}  ${DIM}%s${NC}\n" "$1" "$2"; }

echo ""
pad "Node.js"  "$(node -v 2>/dev/null || echo '✘ not found')"
pad "NPM"      "$(npm -v 2>/dev/null || echo '✘ not found')"
pad "PNPM"     "$(pnpm -v 2>/dev/null || echo '✘ not found')"
pad "Python"   "$(python3.11 --version 2>/dev/null || echo '✘ not found')"
pad "pip"      "$(python3.11 -m pip --version 2>/dev/null | cut -d' ' -f1-2 || echo '✘ not found')"
pad "git"      "$(git --version 2>/dev/null | cut -d' ' -f3 || echo '✘ not found')"
pad "gh"       "$(gh --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo '✘ not found')"
pad "htop"     "$(htop --version 2>/dev/null | head -1 | cut -d' ' -f2 || echo '✘ not found')"
pad "neofetch" "$(neofetch --version 2>/dev/null || echo 'installed')"
echo ""
echo -e "  ${LINE}"
echo ""
echo -e "  ${O}${BOLD}  Ubuntu Noble siap dipakai!${NC}"
echo ""
echo -e "  ${DIM}  Tip:${NC}"
echo -e "  ${DIM}  › 'on'             → aktifkan Python venv${NC}"
echo -e "  ${DIM}  › 'off'            → keluar venv${NC}"
echo -e "  ${DIM}  › 'neofetch'       → lihat info sistem${NC}"
echo -e "  ${DIM}  › source ~/.bashrc → reload alias & PATH${NC}"
echo ""
UBSCRIPT

chmod +x ~/ubuntu-noble/root/setup_ubuntu.sh
ok "setup_ubuntu.sh ditulis ke rootfs"

# ============================================================

section "SELESAI"

echo -e "  ${O}${BOLD}  Ubuntu Noble berhasil diinstall!${NC}"
echo ""
echo -e "  ${LINE}"
echo ""
echo -e "  ${DIM}  1.  Reload shell${NC}"
echo -e "      ${O}  source ~/.bashrc${NC}"
echo ""
echo -e "  ${DIM}  2.  Login ke Ubuntu Noble${NC}"
echo -e "      ${O}  noble${NC}"
echo ""
echo -e "  ${DIM}  3.  Setup tools di dalam Ubuntu${NC}"
echo -e "      ${O}  bash /root/setup_ubuntu.sh${NC}"
echo ""
echo -e "  ${LINE}"
echo ""
