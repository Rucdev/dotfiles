{ pkgs, config, ... }:
{
  # 設定本体ではなく「バイナリ」を Nix に寄せる方針の共通 CLI 群。
  home.packages = with pkgs; [
    hackgen-nf-font

    git
    gh
    nh        # nicer home-manager UX: `nh home switch ~/dotfiles`

    # 日常の便利系（不要なら削る）
    eza
    bat
    fd
    ripgrep
    fzf
    jq
    curl
    wget
  ];

  # nh をパス指定なしで使いたい場合は flake の場所を教えておく。
  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
  };
}