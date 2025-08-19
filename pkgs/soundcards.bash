# Usage:
# $ soundcards next # switch to the next device
# $ soundcards previous # switch to the previous device
# $ soundcards toggle-hdmi # toggle between HDMI and analog profiles

function switch_sink {
    local sink=$2
    local node_id=$(get_node_id_from_sink "$1" "$sink")
    local node_description=$(get_node_info "$1" "$node_id" \"node.description\")
    wpctl set-default "$node_id"
    notify-send "Sound output" "$node_description"
}

function toggle_hdmi_profile {
    local default_sink=$2
    local node_id=$(get_node_id_from_sink "$1" "$default_sink")
    local device_id=$(get_node_info "$1" "$node_id" \"device.id\")
    local node_profile_name=$(get_node_info "$1" "$node_id" \"device.profile.name\")
    local analog_profile="output:analog-stereo+input:analog-stereo"
    local hdmi_profile="output:hdmi-stereo+input:analog-stereo"

    local profile_index
    local profile_name
    if [ "$node_profile_name" = "analog-stereo" ]; then
        profile_index=$(get_profile_index_from_device_id $1 $device_id $hdmi_profile)
        profile_name=$hdmi_profile
    else
        profile_index=$(get_profile_index_from_device_id $1 $device_id $analog_profile)
        profile_name=$analog_profile
    fi

    # We still use pactl for now because wpctl does not change to the saved volume when switching
    pactl set-card-profile "${device_id}" "${profile_name}"
    # wpctl set-profile "${device_id}" "${profile_index}"

    pw-dump -N > $1
    default_sink=$(get_default_sink $1)
    local node_id=$(get_node_id_from_sink "$1" "$default_sink")
    local profile_description=$(get_node_info "$1" "$node_id" \"device.profile.description\")
    notify-send "Sound profile" "$profile_description"
}

function get_node_info {
    local node_id=$2
    local field=$3
    jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .id=='$node_id').info.props.'$field'' $1
}

function get_node_id_from_sink {
    local sink=$2
    jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."node.name"=="'$sink'").id' $1
}

function get_node_id_from_device_id {
    local device_id=$2
    jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."device.id"=="'$device_id'").id' $1
}

function get_profile_index_from_device_id {
    local device_id=$2
    local profile_name=$3
    jq -r '.[] | select(.type=="PipeWire:Interface:Device" and .id=='$device_id').info.params.EnumProfile[] | select(.name=="'$profile_name'").index' $1
}

function get_current_profile_index_from_device_id {
    local device_id=$2
    jq -r '.[] | select(.type=="PipeWire:Interface:Device" and .id=='$device_id').info.params.Profile | first | .index' $1
}

function list_sinks {
    jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Audio/Sink") | .info.props."node.name"' $1 | sort
}

function get_default_sink {
    pw-dump | jq -r '
    (
      .[] |
      select(.type=="PipeWire:Interface:Metadata" and .props."metadata.name"=="default") |
      .metadata
    ) as $m |
    (first($m[] | select(.key=="default.audio.sink").value.name))
    //
    (first($m[] | select(.key=="default.configured.audio.sink").value.name))
  '
}

function get_index_of_element {
    local element=$1
    shift
    local arr=("$@")

    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "${element}" ]]; then
            echo $i
            break
        fi
    done
}

function main {
    local subcommand=$1
    local pw_dump_file=/tmp/pw_dump

    pw-dump -N > /tmp/pw_dump

    local sinks=( $(list_sinks $pw_dump_file) )
    local default_sink=$(get_default_sink $pw_dump_file)
    local default_sink_index=$(get_index_of_element "${default_sink}" ${sinks[@]})
    local nb_sinks=${#sinks[@]}

    if [ "$subcommand" = "next" ]; then
        local next_sink=${sinks[$(( ($default_sink_index + 1) % $nb_sinks ))]}
        switch_sink $pw_dump_file $next_sink
    elif [ "$subcommand" = "previous" ]; then
        local previous_sink=${sinks[$(( $default_sink_index - 1 ))]}
        switch_sink $pw_dump_file $previous_sink
    elif [ "$subcommand" = "toggle-hdmi" ]; then
        toggle_hdmi_profile $pw_dump_file $default_sink
    fi

    rm /tmp/pw_dump
}

main "$@"
