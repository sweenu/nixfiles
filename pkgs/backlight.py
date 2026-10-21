import sys
import re
from pathlib import Path
from subprocess import run, PIPE

BACKLIGHT_CMD = [
    "dms",
    "ipc",
    "call",
    "brightness"
]

I2C_DEVICES = Path("/sys/bus/i2c/devices")
DRM_DEVICES = Path("/sys/class/drm")
INTERNAL_CONNECTORS = ("eDP", "LVDS", "DSI")


def _external_ddc_device() -> str:
    """Returns the dms device id of the connected external monitor's DDC bus.

    amdgpu registers two i2c adapters per connector: "AMDGPU DM i2c hw bus N"
    for the DDC pins and "AMDGPU DM aux hw bus N" for the DisplayPort AUX
    channel. A connector's `ddc` symlink points at the hw bus, but a DP monitor
    answers DDC/CI on the aux one, so swap to the aux adapter when it exists.
    """
    for connector in sorted(DRM_DEVICES.glob("card*-*")):
        if connector.name.split("-", 1)[1].startswith(INTERNAL_CONNECTORS):
            continue
        ddc = connector / "ddc"
        if not ddc.exists():
            continue
        if (connector / "status").read_text().strip() != "connected":
            continue

        bus = ddc.resolve()
        hw_name = (bus / "name").read_text().strip()
        aux_name = hw_name.replace("i2c hw", "aux hw")
        for adapter in I2C_DEVICES.iterdir():
            try:
                if (adapter / "name").read_text().strip() == aux_name:
                    bus = adapter
                    break
            except OSError:
                continue
        return f"ddc:{bus.name}"

    raise SystemExit("backlight: no external monitor connected")


def _get_brightness() -> int:
    output = run(BACKLIGHT_CMD + ["status"], stdout=PIPE).stdout
    output = output.decode("utf-8")
    brightness = re.search(r"Brightness:\s*(\d+)%", output).group(1)
    return int(brightness)


def _increase_brightness(percentage: int) -> None:
    run(BACKLIGHT_CMD + ["increment", str(percentage), ""])


def _decrease_brightness(percentage: int) -> None:
    run(BACKLIGHT_CMD + ["decrement", str(percentage), ""])


def _set_brightness(value: int) -> None:
    run(BACKLIGHT_CMD + ["set", str(value), ""])


def change_backlight(
    action: str,
    range_start: int = 10,
    range_end: int = 20,
    small_step: int = 1,
    big_step: int = 5,
) -> None:
    """Increases or decreases brightness.

    Takes 'dec' or 'inc' as parameter for 'action'.
    Goes `big_step` percent at a time below `range_start`,
    `small_step` percent at a time from `range_start` to `range_end` percent,
    then `big_step` percent at a time from `range_end` to 100 percent.
    """
    current_brightness = _get_brightness()

    if action == "inc":
        if range_start <= current_brightness < range_end:
            _increase_brightness(small_step)
        elif current_brightness < range_start:
            if current_brightness + big_step > range_start:
                _set_brightness(range_start)
            else:
                _increase_brightness(big_step)
        else:
            _increase_brightness(big_step)
    elif action == "dec":
        if range_start < current_brightness <= range_end:
            _decrease_brightness(small_step)
        elif current_brightness > range_end:
            if current_brightness - big_step < range_end:
                _set_brightness(range_end)
            else:
                _decrease_brightness(big_step)
        else:
            _decrease_brightness(big_step)


if __name__ == "__main__":
    action = sys.argv[1]

    if len(sys.argv) > 2 and sys.argv[2] == "external":
        # Flat steps rather than the curve above: the curve needs to read the
        # current brightness back, and `dms brightness status` only ever
        # reports the device dms itself has selected.
        verb = {"inc": "increment", "dec": "decrement"}[action]
        run(BACKLIGHT_CMD + [verb, "5", _external_ddc_device()])
    else:
        change_backlight(action)
