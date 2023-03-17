#!/usr/bin/env bash

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

declare -r resize_step_config='@vim_tmux_navigator_resize_step'

tmux_option() {
  local -r option=$(tmux show-option -gqv "$1")
  local -r fallback="$2"
  echo "${option:-$fallback}"
}

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"

resize_step=$(tmux_option "$resize_step_config" "1")
tmux bind-key -n M-h if-shell "$is_vim" 'send-keys M-h' "resize-pane -L $resize_step"
tmux bind-key -n M-j if-shell "$is_vim" 'send-keys M-j' "resize-pane -D $resize_step"
tmux bind-key -n M-k if-shell "$is_vim" 'send-keys M-k' "resize-pane -U $resize_step"
tmux bind-key -n M-l if-shell "$is_vim" 'send-keys M-l' "resize-pane -R $resize_step"

tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

tmux bind-key -T copy-mode-vi C-h select-pane -L
tmux bind-key -T copy-mode-vi C-j select-pane -D
tmux bind-key -T copy-mode-vi C-k select-pane -U
tmux bind-key -T copy-mode-vi C-l select-pane -R
tmux bind-key -T copy-mode-vi C-\\ select-pane -l
