# dotfiles

Fedora 母艦 + standalone home-manager (flake) で Neovim を管理する構成。

方針:
- **バイナリと周辺ツールは Nix**、**設定本体はプレーンなファイル**。
- 設定は `mkOutOfStoreSymlink` でリポジトリ内の実ファイルへ直リンク
  （編集→即反映、rebuild 不要、Git 管理下）。
- プラグインはランタイム管理（nvim: lazy.nvim）。

## 構成

```
dotfiles/
├─ flake.nix
├─ home/
│  ├─ default.nix      # 共通設定 / Fedora 統合 (genericLinux)
│  ├─ packages.nix     # CLI ツール
│  └─ neovim.nix       # nvim 本体 + LSP/ツール + symlink
└─ config/
   └─ nvim/            # プレーン Lua (lazy.nvim)
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
   nix run home-manager/master -- switch --flake ~/dotfiles#ruc
   ```

5. 以降は:

   ```sh
   home-manager switch --flake ~/dotfiles#ruc
   # または nh home switch ~/dotfiles
   ```

## 初回の後始末

- Neovim: 起動すると lazy.nvim が自動 bootstrap。`:Lazy sync` でプラグイン取得。

## パッケージのアップグレード

パッケージのバージョンは `flake.lock` で固定されている。更新するには lock を上げてから適用する。

1. flake inputs を更新:

   ```sh
   cd ~/dotfiles
   nix flake update              # 全 input (nixpkgs / home-manager / hunk)
   # nix flake update nixpkgs    # 特定の input だけ上げる場合
   ```

2. 差分を確認して適用:

   ```sh
   nh home switch ~/dotfiles     # ビルド前後のパッケージ差分を表示してから switch
   # または home-manager switch --flake ~/dotfiles#ruc
   ```

3. 問題なければ lock をコミット:

   ```sh
   git add flake.lock
   git commit -m "update pkgs"
   ```

ロールバックしたい場合:

```sh
git checkout HEAD~1 -- flake.lock && nh home switch ~/dotfiles
# または直前の世代に戻す
home-manager generations        # 世代一覧
<世代のパス>/activate
```

古い世代・ストアの掃除:

```sh
nh clean user --keep 5          # 直近 5 世代を残して GC
# または nix-collect-garbage --delete-older-than 14d
```

## メモ

- `~/.config/nvim` は symlink。中身はこのリポジトリを編集する。
- tree-sitter パーサを Nix 管理にしたい場合は `home/neovim.nix` のコメント参照。
