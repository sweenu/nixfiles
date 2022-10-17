REASON="User does not want computer to sleep"
CMD="sleep infinity"

if systemd-inhibit --no-pager --no-legend | grep "$REASON"
then
    pkill -f "$CMD"
    notify-send System "Suspend reactivated"
else
    notify-send System "Suspend inhibited"
    # shellcheck disable=SC2086
    systemd-inhibit --what=sleep --who="$USER" --why="$REASON" $CMD
fi
