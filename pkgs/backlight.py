import sys
import re
from subprocess import run, PIPE

BACKLIGHT_CMD = [
    "dms",
    "ipc",
    "call",
    "brightness"
]


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
    change_backlight(sys.argv[1])
