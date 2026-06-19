{ pkgs, config, ... }:
{
  imports = [
    ./packages.nix
    ./neovim.nix
    ./tmux.nix
    ./bash.nix
  ];

  home.username = "ruc";
  home.homeDirectory = "/home/ruc";
  home.stateVersion = "25.11";

  # 非 NixOS で HM を使うときの XDG / セッション変数 / ロケール周りを吸収する。
  # Fedora ではこれを入れておくと後で躓きにくい。
  targets.genericLinux.enable = true;

  # 非 NixOS では XDG_DATA_DIRS を持たない GUI アプリから nix のフォントが見えない。
  # これを有効にすると fontconfig の conf.d に nix プロファイルのフォントディレクトリが
  # 明示登録され、全アプリ（GUI 含む）から HackGen 等を参照できるようになる。
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}