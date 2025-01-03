# Get connected devices
devices=$(dualsensectl -l | grep -oE '[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}')

if [ -z "$devices" ]; then
  echo '[]'
  exit 0
fi

# Get bluetooth devices
bluetooth_devices=$(bluetoothctl devices)

output="["
first=true
for device in $devices; do
  # Get battery status
  battery_status=$(dualsensectl -d "$device" battery 2>/dev/null)
  level=$(echo "$battery_status" | awk '{print $1}')
  status=$(echo "$battery_status" | awk '{print $2}')

  # Get device name/alias
  device_upper=$(echo "$device" | tr '[:lower:]' '[:upper:]')
  device_name=$(echo "$bluetooth_devices" | grep "Device $device_upper" | cut -d' ' -f3- || echo "$device_upper")

  if ! $first; then
    output="$output,"
  fi

  output="$output{\"text\":\"$device_name ($level%)\",\"class\":\"$status\"}"
  first=false
done
output="$output]"

echo "$output"
