root=$(git rev-parse --show-toplevel 2> /dev/null || echo '.')
kak_cmd=$(test -z "$1" && echo "kak" || echo "kak -c $1")

file=$(
  fd --type file . --base-directory "$root" |
  sk --tiebreak=length,score,begin,end,index --preview-window=down:60% --preview "bat --style=numbers --color=always --line-range :500 $root/{}"
)

test -z "$file" || $kak_cmd "$root"/"$file"
