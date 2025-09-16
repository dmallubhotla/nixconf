{
  config,
  pkgs,
  pkgs-unstable,
}:
{
  enable = true;
  package = pkgs-unstable.tmux;
  historyLimit = 100000;
  clock24 = true;
  keyMode = "vi";
  mouse = true;
  prefix = "M-,";
  plugins = [
    pkgs.tmuxPlugins.vim-tmux-navigator
    pkgs.tmuxPlugins.better-mouse-mode
    pkgs.tmuxPlugins.sensible
    pkgs.tmuxPlugins.power-theme
    pkgs.tmuxPlugins.resurrect
  ];
  extraConfig = ''
    set-option -g status-position top
    unbind '"'
    unbind %

    set -s copy-command 'xsel -bi'
    bind -N "Change layout"  -T prefix % next-layout
    bind -N "Horizontal split"    -T prefix | split-window -h -c '#{pane_current_path}'
    bind -N "Horizontal split"    -T prefix \\ split-window -h -c '#{pane_current_path}'
    bind -N "Vertical split"      -T prefix - split-window -v -c '#{pane_current_path}'
    bind -N "Create a new window" -T prefix c new-window -c '#{pane_current_path}'
    bind -N "Quick pane for obsidian todos" -T prefix . split-window -c $DPK_OBSIDIAN_DIR -h "vim todos.md"
    bind -N "Enter copy mode"   -T prefix Space copy-mode
    bind -N "Load buffer from xsel and paste" -T prefix C-p run "xsel -ob | tmux load-buffer - ; tmux paste-buffer"
    set -g escape-time 1
    bind -N "Leave copy mode" -T copy-mode-vi Escape send-keys -X cancel
    bind -N "Leave copy mode" -T copy-mode-vi y      send -X copy-pipe
    bind -N "Selection toggle" -T copy-mode-vi Space  if -F "#{selection_present}" { send -X clear-selection } { send -X begin-selection }
    bind -N "Copy and leave copy-mode" -T copy-mode-vi Enter  send -X copy-pipe-and-cancel
    set-option -g status-right "#[fg=#ffb86c]#[fg=#262626,bg=#ffb86c]#(cat ${config.xdg.cacheHome}/weather/short-weather.txt) #[fg=#3a3a3a,bg=#ffb86c]#[fg=#ffb86c,bg=#3a3a3a]  %T #[fg=#ffb86c,bg=#3a3a3a]#[fg=#262626,bg=#ffb86c]  %F "
  '';
}
