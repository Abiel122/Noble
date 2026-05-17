<div align="center">

```
███╗   ██╗ ██████╗ ██████╗ ██╗     ███████╗
████╗  ██║██╔═══██╗██╔══██╗██║     ██╔════╝
██╔██╗ ██║██║   ██║██████╔╝██║     █████╗  
██║╚██╗██║██║   ██║██╔══██╗██║     ██╔══╝  
██║ ╚████║╚██████╔╝██████╔╝███████╗███████╗
╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
```

**Ubuntu Noble PRoot Installer for Termux**

[![License](https://img.shields.io/badge/license-MIT-orange?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Termux-orange?style=flat-square)](https://termux.dev)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20Noble-orange?style=flat-square)](https://ubuntu.com)
[![Node](https://img.shields.io/badge/Node.js-22-orange?style=flat-square)](https://nodejs.org)
[![Python](https://img.shields.io/badge/Python-3.11-orange?style=flat-square)](https://python.org)
[![Stars](https://img.shields.io/github/stars/Abiel122/Noble?style=flat-square&color=orange)](https://github.com/Abiel122/Noble/stargazers)

</div>

---

## ✦ Tentang

**Noble** adalah installer otomatis Ubuntu 24.04 (Noble Numbat) di atas PRoot Termux — tanpa root, langsung di Android.  
Satu script, semua tools langsung siap: Node.js, PNPM, Python, Git, dan lainnya.

---

## ⚡ Quick Install

Buka **Termux**, lalu jalankan salah satu perintah berikut:

**via curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/Abiel122/Noble/main/noble_installer.sh | bash
```

**via wget:**
```bash
wget -qO- https://raw.githubusercontent.com/Abiel122/Noble/main/noble_installer.sh | bash
```

**atau clone dulu:**
```bash
git clone https://github.com/Abiel122/Noble.git
cd Noble
bash noble_installer.sh
```

---

## 📦 Yang Diinstall

### Di Termux (host)
| Package | Fungsi |
|---------|--------|
| `proot` | Virtualisasi tanpa root |
| `wget` `curl` | Download & HTTP client |
| `tar` | Ekstrak rootfs |

### Di Ubuntu Noble (guest)
| Package | Versi | Fungsi |
|---------|-------|--------|
| **Node.js** | 22.x | JavaScript runtime |
| **NPM** | latest | Node package manager |
| **PNPM** | latest | Fast package manager |
| **Python** | 3.11 | Python runtime |
| **pip** | latest | Python package manager |
| **git** | latest | Version control |
| **gh** | latest | GitHub CLI |
| **htop** | latest | Process monitor |
| **neofetch** | latest | System info |
| **unzip / zip** | latest | Archive tools |
| **nano** | latest | Text editor |

---

## 🚀 Cara Pakai

### 1 — Install
```bash
curl -fsSL https://raw.githubusercontent.com/Abiel122/Noble/main/noble_installer.sh | bash
```

### 2 — Reload shell
```bash
source ~/.bashrc
```

### 3 — Masuk ke Ubuntu
```bash
noble
```

### 4 — Setup tools di dalam Ubuntu
```bash
bash /root/setup_ubuntu.sh
```

### 5 — Selesai! Cek hasilnya
```bash
node -v && pnpm -v && python3 --version && git --version
```

---

## 🗂 Struktur Repo

```
Noble/
├── noble_installer.sh      # Main installer (jalankan di Termux)
└── README.md
```

> `setup_ubuntu.sh` digenerate otomatis ke dalam rootfs saat instalasi.

---

## 💡 Alias yang Tersedia

Setelah setup selesai, alias berikut langsung aktif:

| Alias | Fungsi |
|-------|--------|
| `noble` | Masuk ke Ubuntu Noble |
| `on` | Aktifkan Python virtualenv |
| `off` | Keluar dari virtualenv |

---

## 📋 Requirement

- Android 7.0+ (API 24+)
- [Termux](https://f-droid.org/packages/com.termux/) (dari F-Droid, bukan Play Store)
- Koneksi internet
- Storage ~500MB kosong
- **Tidak perlu root**

---

## 🏗 Arsitektur yang Didukung

| Perangkat | Arsitektur |
|-----------|-----------|
| HP Android (kebanyakan) | `arm64` / `aarch64` |
| HP Android lama | `armhf` |
| Emulator / PC | `amd64` / `x86_64` |

Deteksi arsitektur dilakukan otomatis saat install.

---

## ❓ Troubleshooting

**`proot: command not found`**
```bash
pkg install proot -y
```

**Download gagal / timeout**
```bash
# Coba lagi, atau ganti DNS Termux:
echo "nameserver 1.1.1.1" > $PREFIX/etc/resolv.conf
```

**`noble` command tidak ditemukan setelah install**
```bash
source ~/.bashrc
```

**PPA deadsnakes gagal di dalam Ubuntu**
```bash
# Cek koneksi di dalam noble, lalu:
apt update && add-apt-repository ppa:deadsnakes/ppa -y
```

---

## 📄 License

[MIT](LICENSE) — bebas dipakai, dimodif, dan disebarluaskan.

---

<div align="center">
  <sub>made with ♥ by <a href="https://github.com/Abiel122">keylordelrey</a></sub>
</div>
