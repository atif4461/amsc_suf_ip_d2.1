echo "=== HOST ==="
hostname -f
hostnamectl 2>/dev/null

echo
echo "=== VIRTUALIZATION ==="
systemd-detect-virt 2>/dev/null

echo
echo "=== DMI ==="
for f in \
    sys_vendor product_name product_version product_uuid \
    board_vendor board_name chassis_vendor chassis_asset_tag
do
    printf "%-20s " "$f:"
    cat "/sys/class/dmi/id/$f" 2>/dev/null || echo "unavailable"
done

echo
echo "=== NETWORK ==="
ip addr
ip route

echo
echo "=== NIC DEVICE ==="
for iface in /sys/class/net/*; do
    n=$(basename "$iface")
    echo "$n:"
    printf "  MAC:    "
    cat "$iface/address" 2>/dev/null
    printf "  Device: "
    readlink -f "$iface/device" 2>/dev/null || echo "virtual/no device"
done
