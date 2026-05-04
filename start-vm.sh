pkill -f qemu-system-x86_64
qemu-system-x86_64 -machine q35 -m 2048 -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n1 -drive if=virtio,file=vm.qcow2 -accel tcg,thread=multi -smp 8   -monitor unix:./qemu-monitor.sock,server,nowait -display none -device qemu-xhci,id=xhci0 -loadvm mysnap -daemonize   -qmp unix:./qmp.sock,server,nowait
