# Usage: capture [-o PATH] [slurped-screenshot|modifiable-screenshot|screencast]
# If no type is specified, will take a basic screenshot.
# Will save the captured footage to PATH or to ./ if not specified.

notify() {
    notify-send "Sway" "$1"
}

screenshot() {
    grim "$1"
}

slurped_screenshot() {
    grim -g "$(slurp)" "$1"
}

modifiable_screenshot() {
    grim -g "$(slurp)" - | swappy -f - -o "$1"
}

screencast() {
    wf-recorder -g "$(slurp)" -f "$1"
}

main() {
    while getopts "o:" opt; do
       case "$opt" in
          o) output_dir="$OPTARG";;
          \?) echo unknown flag "$opt"
             exit 1 ;;
       esac
    done
    shift $((OPTIND-1))
    type="$1"
    [ -z "$output_dir" ] && output_dir="."

    filepath="$output_dir/$(date '+screenshot_%Y-%m-%d-%H%M%S.png')"
    case "$type" in
        screenshot|"") screenshot "$filepath";;
        slurped-screenshot) slurped_screenshot "$filepath" ;;
        modifiable-screenshot) modifiable_screenshot "$filepath" ;;
        screencast)
            filepath="$output_dir/$(date '+screencast_%Y-%m-%d-%H%M%S.mp4')";
            if screencast "$filepath"; then
                notify "Screencast saved as\n$(realpath "$filepath")"
                exit 0
            else
                notify "Screencast failed"
                exit 1
            fi ;;
        *)
            echo "Type should be one of screenshot, slurped-screenshot, modifiable-screenshot or screencast"
            exit 1 ;;
    esac

    # shellcheck disable=SC2181
    if [ "$?" -eq 0 ]; then
        notify "Screenshot saved as\n$(realpath "$filepath")"
    else
        notify "Screenshot failed"
    fi
}

main "$@"
