{ pkgs, config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # programs.neovim は使わない。
  # enable = true にすると home-manager が ~/.config/nvim/init.lua を管理ファイルとして
  # 生成し、dotfiles シンボリックリンク経由の同ファイルと衝突するため。
  home.packages = with pkgs; [
    neovim
    nodejs # neovim の Node.js プロバイダ用
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi  = "nvim";
    vim = "nvim";
  };

  # home-manager の home-manager-files ビルドはサンドボックス内で動くため、
  # mkOutOfStoreSymlink でディレクトリを source に指定すると sandbox の $HOME 外と
  # 判定されてビルドが失敗する。activation スクリプトで直接 symlink を張る。
  home.activation.linkNvimConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${config.xdg.configHome}/nvim" ] && [ ! -L "${config.xdg.configHome}/nvim" ]; then
      $DRY_RUN_CMD rm -rf "${config.xdg.configHome}/nvim"
    fi
    run ln -sfn "${dotfiles}/config/nvim" "${config.xdg.configHome}/nvim"
  '';

  # tree-sitter パーサを Nix 管理にする場合（既存の xdg.dataFile 運用に合わせる）。
  # nvim-treesitter をランタイム依存にしないやり方。必要になったら有効化:
  #
  # xdg.dataFile."nvim/site/parser".source =
  #   "${pkgs.symlinkJoin {
  #      name = "nvim-treesitter-parsers";
  #      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  #    }}/parser";
}