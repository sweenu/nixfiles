REASON="User does not want computer to sleep"
CMD="sleep infinity"

if systemd-inhibit --no-pager --no-legend | grep "$REASON"
then
    pkill -f "$CMD"
    notify-send System "Suspend reactivated"
else
    notify-send System "Suspend inhibited"
    systemd-inhibit --what=sleep --who=$USER --why="$REASON" $CMD
fi
