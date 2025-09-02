import sys
from subprocess import run, PIPE

BACKLIGHT_CMD = ["caelestia-shell", "ipc", "call", "brightness"]


def _get_brightness() -> int:
    output = run(BACKLIGHT_CMD + ["get"], stdout=PIPE).stdout
    return float(output.decode("utf-8")) * 100


def _increase_brightness(percentage: int) -> None:
    run(BACKLIGHT_CMD + ["set", f"+{str(percentage)}%"])


def _decrease_brightness(percentage: int) -> None:
    run(BACKLIGHT_CMD + ["set", f"{str(percentage)}%-"])


def _set_brightness(value: str) -> None:
    run(BACKLIGHT_CMD + ["set", value])


def change_backlight(
    action: str,
    limit: int = 10,
    small_step: int = 1,
    big_step: int = 5,
) -> None:
    """Increases or decreases brightness.

    Takes 'dec' or 'inc' as parameter for 'action'.
    Goes `small_step` percent at a time from 1 to `limit` percent then
    `big_step` percent at a time from `limit` to 100 percent.
    """
    current_brightness = _get_brightness()

    if action == "inc":
        if current_brightness < limit:
            if current_brightness < 1:
                _set_brightness("1%")
            else:
                _increase_brightness(small_step)
        else:
            _increase_brightness(big_step)
    elif action == "dec":
        if current_brightness <= limit:
            if current_brightness > 1:
                _decrease_brightness(small_step)
            else:
                _set_brightness("0")
        else:
            _decrease_brightness(big_step)


if __name__ == "__main__":
    change_backlight(sys.argv[1])
