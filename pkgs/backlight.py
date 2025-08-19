import sys
from subprocess import run, PIPE


def _get_brightness() -> int:
    return round(float(run(["light", "-G"], stdout=PIPE).stdout))


def _increase_brightness(percentage: int) -> None:
    run(["light", "-A", str(percentage)])


def _decrease_brightness(percentage: int) -> None:
    run(["light", "-U", str(percentage)])


def _set_brightness(percentage: int) -> None:
    run(["light", "-S", str(percentage)])


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
                _set_brightness(1)
            else:
                _increase_brightness(small_step)
        else:
            _increase_brightness(big_step)
    elif action == "dec":
        if current_brightness <= limit:
            if current_brightness > 1:
                _decrease_brightness(small_step)
            else:
                _set_brightness(0.01)
        else:
            _decrease_brightness(big_step)


if __name__ == "__main__":
    change_backlight(sys.argv[1])
