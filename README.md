# python-template

Python プロジェクトのテンプレートです。新規プロジェクトの起点として利用できます。

## 構成

```
.
├── .editorconfig           # エディタ共通設定
├── .gitattributes          # 改行コード (LF) とバイナリファイルの扱い
├── .gitignore
├── .python-version         # Python バージョン固定 (uv)
├── .vscode/
│   ├── extensions.json     # 推奨拡張機能 (Ruff / Python など)
│   ├── launch.json         # デバッグ構成
│   └── settings.json       # ワークスペース設定 (保存時フォーマット)
├── pyproject.toml          # プロジェクト定義・依存関係・ツール設定
├── uv.lock
├── LICENSE
├── src/
│   └── python_template/    # パッケージ本体
│       ├── __init__.py     # 公開 API
│       ├── __main__.py     # python -m 用エントリ
│       ├── cli.py          # 引数解析と main
│       └── greet.py        # ライブラリ関数
├── tests/
│   ├── test_cli.py
│   └── test_greet.py
└── scripts/
    ├── common/                 # 共通ヘルパー
    │   ├── cd-project-root.sh
    │   ├── cd-project-root.ps1
    │   └── wait-if-double-clicked.ps1
    ├── linux/                  # Linux 向けエントリポイント
    │   ├── build.sh
    │   ├── run.sh
    │   ├── test.sh
    │   ├── lint.sh
    │   ├── format.sh
    │   ├── check.sh
    │   └── rename-project.sh
    ├── macos/                  # macOS 向けエントリポイント
    │   ├── build.sh
    │   ├── run.sh
    │   ├── test.sh
    │   ├── lint.sh
    │   ├── format.sh
    │   ├── check.sh
    │   └── rename-project.sh
    └── windows/                # Windows 向けエントリポイント
        ├── build.ps1
        ├── run.ps1
        ├── test.ps1
        ├── lint.ps1
        ├── format.ps1
        ├── check.ps1
        └── rename-project.ps1
```

## 使い方

### 前提

- [uv](https://docs.astral.sh/uv/) がインストールされていること
- **Windows**: [PowerShell 7 以上](https://github.com/PowerShell/PowerShell/releases) (`pwsh`)。スクリプトは UTF-8 (BOM なし) です。エクスプローラーからダブルクリックで実行した場合は、結果を確認できるよう Enter 待ちになります (ターミナルからの実行では待ちません)。

```powershell
# uv のインストール例 (Windows)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 1. テンプレートから新規プロジェクトを作る

```bash
git clone <Template Repo URL> my-project
cd my-project
rm -rf .git
git init
uv sync
```

### 2. プロジェクト名を変更する

スクリプトで一括変更する場合 (推奨):

**Linux**

```bash
./scripts/linux/rename-project.sh my-project
./scripts/linux/rename-project.sh my-project "Your Name"   # 著作権者も同時に更新
```

**macOS**

```bash
./scripts/macos/rename-project.sh my-project
./scripts/macos/rename-project.sh my-project "Your Name"   # 著作権者も同時に更新
```

**Windows**

```powershell
./scripts/windows/rename-project.ps1 my-project
./scripts/windows/rename-project.ps1 my-project "Your Name"
```

`pyproject.toml` の `name` を変更し、ハイフン区切りの名前は Python の識別子規則に合わせてアンダースコアに置き換えます。

| pyproject.toml の `name` | Python 識別子 (`import` など) |
| ------------------------ | ------------------------------- |
| `my-project`             | `my_project`                    |
| `my_app`                 | `my_app`                        |

スクリプトが自動で更新する箇所:

- `pyproject.toml` の `name` と `[project.scripts]` のエントリ
- `src/` 配下のパッケージディレクトリ名
- `tests/` の `import` 文
- `src/*/__init__.py` の doc コメント
- `.vscode/launch.json` のモジュール名
- `uv.lock` (`uv lock` で再生成)
- (第 2 引数指定時) `LICENSE` の著作権表記

手動で更新が必要な箇所:

- `pyproject.toml` の `description`, `authors`, `repository` など
- `README.md` のタイトル

### 3. ビルド・実行・テスト

`uv` を直接使う場合:

```bash
uv sync
uv run python-template
uv run pytest
uv run ruff check
uv run ruff format
uv run pyright
uv build
```

スクリプトを使う場合 (どこから実行してもプロジェクトルートに移動してから実行します):

**Linux**

```bash
./scripts/linux/build.sh
./scripts/linux/run.sh Alice --count 2    # 以降の引数をアプリへ渡す
./scripts/linux/test.sh
./scripts/linux/lint.sh
./scripts/linux/format.sh
./scripts/linux/check.sh          # CI 向け一括チェック (format / lint / typecheck / test)
```

**macOS**

```bash
./scripts/macos/build.sh
./scripts/macos/run.sh Alice --count 2    # 以降の引数をアプリへ渡す
./scripts/macos/test.sh
./scripts/macos/lint.sh
./scripts/macos/format.sh
./scripts/macos/check.sh          # CI 向け一括チェック (format / lint / typecheck / test)
```

**Windows**

```powershell
./scripts/windows/build.ps1
./scripts/windows/run.ps1 Alice --count 2  # 以降の引数をアプリへ渡す
./scripts/windows/test.ps1
./scripts/windows/lint.ps1
./scripts/windows/format.ps1
./scripts/windows/check.ps1       # CI 向け一括チェック (format / lint / typecheck / test)
```

## 含まれる設定

- **Python 3.13** (`.python-version` と `requires-python` で固定)
- **Ruff** (Lint / フォーマット)
- **Pyright** (型チェック)
- **pytest** (テスト)
- **src レイアウト** (`src/python_template/` パッケージ)
- **コンソールスクリプト** (`[project.scripts]` → `uv run python-template`)
- **エディタ設定** (`.editorconfig`, `.gitattributes`, `.vscode/` で Ruff 推奨・保存時フォーマット)

## ライセンス

MIT (利用時に `pyproject.toml` の `authors` や `LICENSE` を適宜変更してください)
