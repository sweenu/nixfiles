screenshot="Screenshot"
slurped_screenshot="Screenshot (slurped)"
modifiable_screenshot="Screenshot (modifiable)"
screencast="Screencast"
options="$screenshot\n$slurped_screenshot\n$modifiable_screenshot\n$screencast"

screenshot_folder=$1
screencast_folder=$2

case $(echo -e $options | wofi -d -p "Capture") in
    $screenshot) sway-capture -o $screenshot_folder screenshot ;;
    $slurped_screenshot) sway-capture -o $screenshot_folder slurped-screenshot ;;
    $modifiable_screenshot) sway-capture -o $screenshot_folder modifiable-screenshot ;;
    $screencast) sway-capture -o $screencast_folder screencast ;;
esac
