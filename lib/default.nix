final: prev: {
  lib = prev.lib.extend (lfinal: lprev:
    {
      hyprMoveWsToMonitor = ws: monitor: "hyprctl dispatch moveworkspacetomonitor ${ws} ${monitor}";
      openTCPPortForLAN = port: "iptables -I INPUT -p tcp -s 192.168.1.0/24 --dport ${builtins.toString port} -j ACCEPT";
      openUDPPortForLAN = port: "iptables -I INPUT -p udp -s 192.168.1.0/24 --dport ${builtins.toString port} -j ACCEPT";

    });
}
