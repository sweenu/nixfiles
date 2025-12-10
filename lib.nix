{
  hyprMoveWsToMonitor =
    ws: "hyprctl dispatch moveworkspacetomonitor ${builtins.toString ws} $SHIKANE_OUTPUT_NAME";
  openTCPPortForLAN =
    port:
    "iptables -A nixos-fw -p tcp -s 192.168.1.0/24 --dport ${builtins.toString port} -j nixos-fw-accept";

  openUDPPortForLAN =
    port:
    "iptables -A nixos-fw -p udp -s 192.168.1.0/24 --dport ${builtins.toString port} -j nixos-fw-accept";

  openTCPPortRangeForLAN =
    from: to:
    "iptables -A nixos-fw -p tcp -s 192.168.1.0/24 --dport ${builtins.toString from}:${builtins.toString to} -j nixos-fw-accept";

  openUDPPortRangeForLAN =
    from: to:
    "iptables -A nixos-fw -p udp -s 192.168.1.0/24 --dport ${builtins.toString from}:${builtins.toString to} -j nixos-fw-accept";
}
