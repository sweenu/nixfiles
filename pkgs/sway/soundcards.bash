# Usage:
# $ soundcards next # switch to the next device
# $ soundcards previous # switch to the previous device

function set_default_sink {
    local sink=$1
    pw-metadata 0 default.configured.audio.sink "{ \"name\": \"${sink}\" }" > /dev/null
}

function move_sink_input {
    local sink_input_id=$1
    pw-metadata -d $sink_input_id target.node > /dev/null
}

function switch_sink {
    local pw_dump_file=$1
    local sink=$2
    set_default_sink $sink
    for input_id in $(list_sink_input_ids $pw_dump_file); do
        move_sink_input $input_id
    done
    notify-send "Sound card" "$(get_card_name_from_sink $1 $2)"
}

function get_card_name_from_sink {
    local sink=$2
    cat $1 | jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Audio/Sink" and .info.props."node.name"=="'$sink'") | .info.props."node.description"'
}

function get_current_sink {
    cat $1 | jq -r '.[] | select(.type=="PipeWire:Interface:Metadata" and .props."metadata.name"=="default") | .metadata[] | select(."key"=="default.configured.audio.sink") | .value.name'
}

function list_sinks {
    cat $1 | jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Audio/Sink") | .info.props."node.name"' | sort
}

function list_sink_input_ids {
    cat $1 | jq -r '.[] | select(.type=="PipeWire:Interface:Node" and .info.props."media.class"=="Stream/Output/Audio") | .id' | sort
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
    local direction=$1
    local pw_dump_file=/tmp/pw_dump

    pw-dump -N > $pw_dump_file

    local sinks=( $(list_sinks $pw_dump_file) )
    local current_sink=$(get_current_sink $pw_dump_file)
    local current_sink_index=$(get_index_of_element "${current_sink}" ${sinks[@]})
    local nb_sinks=${#sinks[@]}

    if [ $direction = "next" ]; then
        local next_sink=${sinks[$(( ($current_sink_index + 1) % $nb_sinks ))]}
        switch_sink $pw_dump_file $next_sink
    elif [ $direction = "previous" ]; then
        local previous_sink=${sinks[$(( $current_sink_index - 1 ))]}
        switch_sink $pw_dump_file $previous_sink
    fi

    rm /tmp/pw_dump
}

main "$@"
