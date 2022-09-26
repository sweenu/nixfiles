# Usage: capture PATH [slurped-screenshot|modifiable-screenshot|screencast]
# If no type is specified, will take a basic screenshot.
# Will save the captured footage to PATH.

set -ex

notify() {
    notify-send "Sway" "$1"
}

screenshot() {
    grim $1
}

slurped_screenshot() {
    grim -g $(slurp) $1
}

modifiable_screenshot() {
    grim -g $(slurp) | swappy -f - -o $1
}

screencast() {
    wf-recorder -g $(slurp) -o $1
}

main() {
    output_dir=$1
    type=$2

    if [ $type = "screencast" ]; then
        filepath="$output_dir/$(date '+screencast_%Y-%m-%d-%H%M%S.mp4')";
        screencast $filepath
        notify "Screencast saved as $filepath"
        exit 0
    fi

    filepath="$output_dir/$(date '+screenshot_%Y-%m-%d-%H%M%S.png')"

    case $type in
        "slurped-screenshot") slurped_screenshot $filepath;;
        "modifiable-screenshot") modifiable_screenshot $filepath;;
        "modifiable-screenshot") modifiable_screenshot $filepath;;
        "*") screenshot;;
    esac
    notify "Screenshot saved as $filepath"
}
