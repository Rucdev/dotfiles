# dotfiles

Fedora 母艦 + standalone home-manager (flake) で Neovim / tmux を管理する構成。

方針:
- **バイナリと周辺ツールは Nix**、**設定本体はプレーンなファイル**。
- 設定は `mkOutOfStoreSymlink` でリポジトリ内の実ファイルへ直リンク
  （編集→即反映、rebuild 不要、Git 管理下）。
- プラグインはランタイム管理（nvim: lazy.nvim / tmux: tpm）。

## 構成

```
dotfiles/
├─ flake.nix
├─ home/
│  ├─ default.nix      # 共通設定 / Fedora 統合 (genericLinux)
│  ├─ packages.nix     # CLI ツール
│  ├─ neovim.nix       # nvim 本体 + LSP/ツール + symlink
│  └─ tmux.nix         # tmux 本体 + tpm + symlink
└─ config/
   ├─ nvim/            # プレーン Lua (lazy.nvim)
   └─ tmux/tmux.conf   # プレーン tmux.conf (tpm)
```

## ブートストラップ

1. Nix を入れる（Determinate Systems インストーラ。SELinux 対応 + flakes 既定 ON）:

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L \
     https://install.determinate.systems/nix | sh -s -- install
   ```

2. このリポジトリを `~/dotfiles` に clone:

   ```sh
   git clone <your-repo> ~/dotfiles
   ```

3. `home/default.nix` の `home.username` / `home.homeDirectory` を自分の値に変更。

4. 初回適用（home-manager 未インストール状態から）:

   ```sh
   nix run home-manager/master -- switch --flake ~/dotfiles#yushi@fedora
   ```

5. 以降は:

   ```sh
   home-manager switch --flake ~/dotfiles#yushi@fedora
   # または nh home switch ~/dotfiles
   ```

## 初回の後始末

- Neovim: 起動すると lazy.nvim が自動 bootstrap。`:Lazy sync` でプラグイン取得。
- tmux: `tmux` 起動後 `prefix + I`（C-a then I）で tpm がプラグイン取得。
  tpm 自体は HM の activation で自動 clone 済み。

## メモ

- `~/.config/nvim` と `~/.config/tmux/tmux.conf` は symlink。中身はこのリポジトリを編集する。
- tree-sitter パーサを Nix 管理にしたい場合は `home/neovim.nix` のコメント参照。
