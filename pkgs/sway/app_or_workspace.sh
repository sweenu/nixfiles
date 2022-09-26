# Usage: app_or_workspace <app name> <workspace name>

function workspace_exist {
    swaymsg -rt get_workspaces | jq -e ".[] | select(.name==\"$1\")"
}

function goto_workspace {
    swaymsg workspace $1
}

function open_app_and_go_to_workspace {
    local app=$1
    local workspace=$2

    goto_workspace $workspace && $app
}

function main {
    local app=$1
    local workspace=$2

    workspace_exist $workspace && goto_workspace $workspace || open_app_and_go_to_workspace $app $workspace
}

main $@
