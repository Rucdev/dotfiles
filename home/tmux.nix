{ pkgs, config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # バイナリだけ Nix。設定は触れず、programs.tmux は使わない。
  home.packages = [ pkgs.tmux ];

  # tmux 3.1+ は ~/.config/tmux/tmux.conf を読む。プレーンな conf を直リンク。
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/tmux/tmux.conf";

  # プラグインは nvim の lazy.nvim と同じく「ランタイムで管理」。
  # tpm を初回だけ自動 clone しておく（手動で clone してもよい）。
  home.activation.installTpm = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    TPM_DIR="${config.home.homeDirectory}/.config/tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
      run ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi
  '';
}