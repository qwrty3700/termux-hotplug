#!/data/data/com.termux/files/usr/bin/bash
pkill -f usbredir
PORT="127.0.0.1:4000"
DEVICE_INDEX=0
QMP_SOCK="$PWD/qmp.sock"
echo "[+] Detecting USB device..."

USB_DEVICE=$(termux-usb -l | grep -oE '"/dev/bus/usb/[0-9]+/[0-9]+"' | sed -n "$((DEVICE_INDEX+1))p" | tr -d '"')
USB_ID=$(echo "$USB_DEVICE" | awk -F'/' '{print $5 "-" $6}')
if [ -z "$USB_DEVICE" ]; then
    echo "[-] No USB device found"
    exit 1
fi

echo "[+] Using device: $USB_DEVICE"
termux-usb -r "$USB_DEVICE"
termux-usb -Ee "./usbredirect -k --as 127.0.0.1:4000 --device $USB_ID" "$USB_DEVICE" &
sleep 1

{
echo '{ "execute": "qmp_capabilities" }'
echo '{
  "execute": "device_del",
  "arguments": { "id": "usb1" }
}'

echo '{
  "execute": "chardev-add",
  "arguments": {
    "id": "testusb1",
    "backend": {
      "type": "socket",
      "data": {
        "addr": {
          "type": "inet",
          "data": {
            "host": "127.0.0.1",
            "port": "4000"
          }
        },
        "server": false
      }
    }
  }
}'

echo '{
  "execute": "device_add",
  "arguments": {
    "driver": "usb-redir",
    "id": "usb1",
    "chardev": "testusb1",
    "bus": "xhci0.0"
  }
}'


} | socat - UNIX-CONNECT:$QMP_SOCK

echo "[+] Done"
