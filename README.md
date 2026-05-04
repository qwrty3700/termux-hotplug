# Termux QEMU Hotplug

Run a headless x86_64 VM in Termux with USB device hot-plug support.

## Quick Start

```bash
# 1. Install everything (QEMU, socat, sshpass, downloads 723 MB VM disk)
./install.sh

# 2. Start the VM (loads from 'mysnap' snapshot)
./start-vm.sh

# 3. SSH into the VM
./shell.sh          # user: root / password: toor

# 4. Hot-plug a USB device
./hotplug.sh        # attaches first detected USB device

# 5. Stop the VM
./stop-vm.sh
```

## Requirements

| Package | Source |
|---|---|
| `qemu-system-x86-64-headless` | `pkg install` |
| `termux-api` (with `termux-usb`) | [F-Droid](https://f-droid.org/packages/com.termux.api/) |
| `socat` | `pkg install` |
| `sshpass` | `pkg install` |

## VM Specs

- **Architecture:** x86_64 (QEMU system emulation)
- **Machine:** Q35
- **RAM:** 2 GB
- **CPU:** 8 cores
- **Disk:** virtio (qcow2, ~723 MB)
- **Network:** user-mode NAT, SSH forwarded to `localhost:2222`
- **USB:** PCIe xHCI controller + usb-redir for hot-plug

## SSH Access

| Detail | Value |
|---|---|
| Host | `localhost` |
| Port | `2222` |
| User | `root` |
| Password | `toor` |

```bash
ssh root@localhost -p 2222
# or
./shell.sh
```

## USB Hot-Plug

1. Plug in a USB device
2. Run `./hotplug.sh` — it auto-detects and attaches via usbredir
3. The device appears inside the VM as a new USB peripheral

## Snapshot Management

The VM loads from the `mysnap` snapshot on every start. To save changes:

```bash
# Inside the VM, create a checkpoint via QMP:
echo '{"execute":"qmp_capabilities"}' | socat - UNIX-CONNECT:/path/to/qmp.sock
echo '{"execute":"snapshot-save", "arguments":{"target":"mysnap"}}' | socat - UNIX-CONNECT:/path/to/qmp.sock
```

## License

MIT
