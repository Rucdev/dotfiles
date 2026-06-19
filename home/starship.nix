{ pkgs, config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # バイナリは packages.nix。init は bashrc。設定だけ実ファイルへ直リンク（編集→即反映）。
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/starship/starship.toml";
}
