{ config, pkgs, ... }:

let
  say-hello = pkgs.stdenv.mkDerivation {
    name = "hello";
    PATH = "${pkgs.coreutils}/bin";
    builder = pkgs.writeShellScript "hello" ''
      mkdir -p "$out/bin"
      echo "echo '$greeting'" >> "$out/bin/hello"
      chmod +x "$out/bin/hello"
    '';
    greeting = "Hello world";
  };
in {
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = { l = "ls -la"; };
    enableSyntaxHighlighting = true;
  };

  programs.tmux.enable = true;
  programs.vim.enable = true;

  home.packages = [ say-hello ];

  home.file = {
    ".config/some-config/some-config.txt" = {
      text = ''
        some text
      '';
    };
    ".tmux.conf" = {
      text = ''
        unbind C-b
        set -g prefix C-a
        bind C-a send-prefix

        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        is_fzf="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?fzf$'"

        bind -n C-< run "mpc prev"
        bind -n C-h run "($is_vim && tmux send-keys C-h) || \
                                  tmux select-pane -L"
        bind -n C-j run "($is_vim && tmux send-keys C-j)  || \
                                 ($is_fzf && tmux send-keys C-j) || \
                                 tmux select-pane -D"
        bind -n C-k run "($is_vim && tmux send-keys C-k) || \
                                  ($is_fzf && tmux send-keys C-k)  || \
                                  tmux select-pane -U"
        bind -n C-l run  "($is_vim && tmux send-keys C-l) || \
                                  tmux select-pane -R"
        bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

        bind-key -T copy-mode-vi C-h select-pane -L
        bind-key -T copy-mode-vi C-j select-pane -D
        bind-key -T copy-mode-vi C-k select-pane -U
        bind-key -T copy-mode-vi C-l select-pane -R
        bind-key -T copy-mode-vi C-\\ select-pane -l

        unbind C-[
        bind -n C-Space copy-mode

        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        bind-key -r -T prefix C-k resize-pane -U 5
        bind-key -r -T prefix C-j resize-pane -D 5
        bind-key -r -T prefix C-h resize-pane -L 5
        bind-key -r -T prefix C-l resize-pane -R 5

        bind-key -T copy-mode-vi v send-keys -X begin-selection
      '';
    };
  };
}

