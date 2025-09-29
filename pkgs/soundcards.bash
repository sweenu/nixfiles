# Usage:
# $ soundcards next # switch to the next available device
# $ soundcards previous # switch to the previous available device

function switch_sink {
    local sink=$2
    local node_id=$(get_node_id_from_sink "$1" "$sink")
    local node_nick=$(get_node_info "$1" "$node_id" "node.nick")
    if [[ -z "$node_nick" || "$node_nick" == "null" ]]; then
        node_nick=$(get_node_info "$1" "$node_id" "node.description")
    fi

    wpctl set-default "$node_id"
    # notify-send --icon=audio-volume-high "Sound output" "$node_nick"
}

function get_node_info {
    jq -r \
        --argjson node_id $2 \
        --arg field $3 \
        '.[] | select(.type=="PipeWire:Interface:Node" and .id==$node_id).info.props[$field]' $1
}

function get_node_id_from_sink {
    jq -r \
        --arg sink "$2" \
        '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."node.name"==$sink).id' $1
}

function list_sinks {
    jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Audio/Sink")
        | .info.props."node.name"' $1 | sort
}

function get_route_availability {
    jq -r \
        --argjson device_id $2 \
        --arg device_profile_description "$3" \
        '.[] | select(.type=="PipeWire:Interface:Device" and .id==$device_id).info.params.EnumRoute[]?
        | select(.description==$device_profile_description).available // empty' $1
}

function is_sink_available {
    local pw_dump_file=$1
    local sink_name=$2

    local node_id=$(get_node_id_from_sink "$pw_dump_file" "$sink_name")
    local device_id=$(get_node_info "$pw_dump_file" "$node_id" "device.id")
    local device_profile_description=$(get_node_info "$pw_dump_file" "$node_id" "device.profile.description")

    # If we can't get device info, assume it's available (e.g., software sinks)
    if [[ -z "$device_id" || -z "$device_profile_description" || "$device_id" == "null" ]]; then
        echo "yes"
        return
    fi

    local availability=$(get_route_availability "$pw_dump_file" "$device_id" "$device_profile_description")
    if [[ "$availability" != "no" ]]; then
        echo "yes"  # Default to available if not found
    else
        echo "$availability"
    fi
}

function list_available_sinks {
    local pw_dump_file=$1
    local all_sinks=($(list_sinks "$pw_dump_file"))

    for sink in "${all_sinks[@]}"; do
        if [[ "$(is_sink_available "$pw_dump_file" "$sink")" == "yes" ]]; then
            echo "$sink"
        fi
    done | sort
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

    local sinks=( $(list_available_sinks $pw_dump_file) )
    local default_sink=$(get_default_sink $pw_dump_file)
    local default_sink_index=$(get_index_of_element "${default_sink}" ${sinks[@]})
    local nb_sinks=${#sinks[@]}

    if [[ $nb_sinks -eq 0 ]]; then
        notify-send --icon=audio-volume-high "Sound output" "No available audio devices found"
        rm /tmp/pw_dump
        exit 1
    fi

    if [ "$subcommand" = "next" ]; then
        local next_sink=${sinks[$(( ($default_sink_index + 1) % $nb_sinks ))]}
        switch_sink $pw_dump_file $next_sink
    elif [ "$subcommand" = "previous" ]; then
        local previous_sink=${sinks[$(( ($default_sink_index - 1 + $nb_sinks) % $nb_sinks ))]}
        switch_sink $pw_dump_file $previous_sink
    else
        echo "Usage: soundcards {next|previous}"
        rm /tmp/pw_dump
        exit 1
    fi

    rm /tmp/pw_dump
}

main "$@"
