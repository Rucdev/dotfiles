{ pkgs, config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # バイナリだけ Nix。設定は触れず、programs.bash は使わない。
  # プレーンな bashrc をリポジトリ内の実ファイルへ直リンク（編集→即反映）。
  home.file.".bashrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/bash/bashrc";
}
