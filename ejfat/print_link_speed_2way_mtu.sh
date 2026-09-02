#!/usr/bin/env bash
# usage: bash print_link_speed_2way_mtu.sh 192.188.29.6

ip="$1"

if [[ -z "$ip" ]]; then
  echo "Usage: $0 <IP>"
  exit 1
fi

iface=$(ip route get "$ip" 2>/dev/null | awk '/dev/ {
  for (i=1; i<=NF; i++)
    if ($i=="dev") { print $(i+1); exit }
}')

if [[ -z "$iface" ]]; then
  echo "Could not determine interface for $ip"
  exit 1
fi

echo "Destination:  $ip"
echo "Interface:    $iface"

device_path=$(readlink -f "/sys/class/net/$iface/device" 2>/dev/null)

if [[ "$device_path" == *"/virtio"* ]]; then
  echo "Type:         virtual (virtio)"
elif [[ -z "$device_path" ]]; then
  echo "Type:         likely virtual"
else
  echo "Type:         physical/device-backed"
fi

mtu=$(cat "/sys/class/net/$iface/mtu" 2>/dev/null)

if [[ -n "$mtu" ]]; then
  echo "Local MTU:    $mtu bytes"
else
  echo "Local MTU:    unknown"
fi

speed=$(cat "/sys/class/net/$iface/speed" 2>/dev/null)
duplex=$(cat "/sys/class/net/$iface/duplex" 2>/dev/null)

if [[ -z "$speed" || "$speed" == "-1" ]]; then
  echo "Link speed:   unknown/unavailable"
else
  if (( speed >= 1000 )); then
    formatted_speed=$(awk -v s="$speed" 'BEGIN { printf "%g Gbps", s/1000 }')
  else
    formatted_speed="$speed Mbps"
  fi

  echo "Link speed:   $formatted_speed"

  if [[ "$duplex" == "full" ]]; then
    echo "Duplex:       full"
    echo "Transmit:     up to $formatted_speed"
    echo "Receive:      up to $formatted_speed"
  elif [[ "$duplex" == "half" ]]; then
    echo "Duplex:       half"
  else
    echo "Duplex:       unknown"
  fi
fi

echo
echo "Path MTU tests:"

if ping -4 -c 2 -W 1 -M do -s 1472 "$ip" >/dev/null 2>&1; then
  echo "MTU 1500:    supported"
else
  echo "MTU 1500:    failed/unknown"
fi

if ping -4 -c 2 -W 1 -M do -s 8972 "$ip" >/dev/null 2>&1; then
  echo "MTU 9000:    supported"
else
  echo "MTU 9000:    failed/unknown"
fi
