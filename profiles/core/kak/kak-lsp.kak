### kak-lsp ###
eval %sh{kak-lsp --kakoune -s $kak_session}

# Enable logs
# eval %sh{echo ${kak_opt_lsp_cmd} >> /tmp/kak-lsp.log}
# set global lsp_cmd "kak-lsp -s %val{session} -vvv --log /tmp/kak-lsp.log"

set global lsp_diagnostic_line_error_sign "║"
set global lsp_diagnostic_line_warning_sign "┊"
set global lsp_auto_highlight_references true
set global lsp_hover_anchor false

map global user r ":lsp-rename-prompt<ret>" -docstring "LSP rename the selected symbol"
map global goto p "<esc>: lsp-implementation<ret>" -docstring "implementation"

hook global WinSetOption filetype=(rust|python|go|nix) %{
    lsp-auto-hover-enable
    lsp-enable-window
}
hook global KakEnd .* lsp-exit
