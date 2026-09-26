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

    # LSP サーバー (mason の代わりに Nix で管理)
    # nvim 側は config/nvim/lua/plugins/lsp.lua の servers に追記して vim.lsp.enable する。
    # nvim-lspconfig のデフォルト cmd が PATH 上のバイナリを探すので、ここに入れるだけで動く。
    lua-language-server # lua_ls
    nil                 # nil_ls (Nix)
    gopls               # gopls (Go)
    rust-analyzer       # rust_analyzer (Rust)
    typescript-language-server # ts_ls (TypeScript / JavaScript)
    typescript          # ts_ls / astro が tsserver 本体として参照する
    ty                  # ty (Python, Astral 製)
    astro-language-server # astro
    svelte-language-server # svelte
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