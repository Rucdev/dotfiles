{ pkgs, config, ... }:
{
  # 設定本体ではなく「バイナリ」を Nix に寄せる方針の共通 CLI 群。
  home.packages = with pkgs; [
    hackgen-nf-font

    git
    gh
    ghq       # リポジトリを ~/ghq 配下に整理して clone
    lazygit   # git の TUI
    nh        # nicer home-manager UX: `nh home switch ~/dotfiles`

    # シェル統合は config/bash/bashrc 内の init で有効化済み
    zoxide    # `z` で賢い cd
    starship  # プロンプト

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