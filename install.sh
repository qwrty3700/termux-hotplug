#!/data/data/com.termux/files/usr/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }

# ── Pre-flight checks ──────────────────────────────────────────────
[ "$(id -u)" -eq 0 ] && error "Do NOT run as root. Run as regular user."

info "Updating package lists..."
pkg update -y || pkg upgrade -y

# ── 1. QEMU (x86_64 headless) ────────────────────────────────────
info "Checking QEMU..."
if command -v qemu-system-x86_64 &>/dev/null; then
    warn "QEMU already installed: $(qemu-system-x86_64 --version | head -1)"
else
    pkg install -y qemu-system-x86-64-headless
    info "QEMU version: $(qemu-system-x86_64 --version | head -1)"
fi

# ── 2. Termux API (check via termux-usb command) ───────────────────
info "Checking Termux API..."
if command -v termux-usb &>/dev/null; then
    info "Termux API is available (termux-usb found)"
else
    error "Termux API not found. Install Termux:API from F-Droid: https://f-droid.org/packages/com.termux.api/"
fi

# ── 3. socat (QMP socket communication) ────────────────────────────
info "Checking socat..."
if command -v socat &>/dev/null; then
    warn "socat already installed"
else
    pkg install -y socat
    info "socat installed"
fi

# ── 4. sshpass (headless SSH into VM) ──────────────────────────────
info "Checking sshpass..."
if command -v sshpass &>/dev/null; then
    warn "sshpass already installed"
else
    pkg install -y sshpass
    info "sshpass installed"
fi

# ── Summary ────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
info  "Installation complete!"
echo "═══════════════════════════════════════"
echo ""
echo "Installed:"
echo "  • QEMU        : $(qemu-system-x86_64 --version | head -1)"
echo "  • socat       : $(socat -V 2>&1 | head -1 || echo 'installed')"
echo "  • sshpass     : $(sshpass -V 2>&1 | head -1 || echo 'installed')"
echo "  • termux-usb  : available"
echo ""
echo "Next steps:"
echo "  1. ./start-vm.sh     – Start the VM"
echo "  2. ./shell.sh        – SSH into the VM"
echo "  3. ./hotplug.sh      – Hot-plug a USB device"
echo "  4. ./stop-vm.sh      – Stop the VM"
echo ""
