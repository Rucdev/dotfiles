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

  # tree-sitter のパーサとクエリを Nix で管理する。
  # nvim-treesitter はプラグインとしては読み込まず、パーサ (.so) とクエリ (.scm) だけを
  # ~/.local/share/nvim/site (stdpath("data")/site = runtimepath) に置く。
  # ハイライトの開始は config/nvim/lua/plugins/treesitter.lua の FileType autocmd で行う。
  # 言語を増やすときは下のリストに追記する (クエリは全言語分入っている)。
  xdg.dataFile."nvim/site/parser".source =
    "${pkgs.symlinkJoin {
       name = "nvim-treesitter-parsers";
       paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
         svelte
         astro
         html
         css
         javascript
         typescript
         tsx
         json
         go
         rust
         python
         nix
         bash
         yaml
         toml
       ])).dependencies;
     }}/parser";

  xdg.dataFile."nvim/site/queries".source =
    "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";
}