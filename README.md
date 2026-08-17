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
│   ├── tasks.json          # デバッグ前に .venv が無ければ uv sync
│   └── settings.json       # ワークスペース設定 (保存時フォーマット)
├── pyproject.toml          # プロジェクト定義・依存関係・ツール設定
├── uv.lock
├── LICENSE
├── src/
│   └── python_template/    # パッケージ本体
│       ├── __init__.py     # 公開 API (__version__ 含む)
│       ├── __main__.py     # python -m 用エントリ
│       ├── cli.py          # 引数解析と main
│       ├── greet.py        # ライブラリ関数
│       └── py.typed        # PEP 561 型情報マーカー
├── tests/
│   ├── test_cli.py
│   ├── test_greet.py
│   └── test_package.py
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
./scripts/linux/rename-project.sh my-project "Your Name"                  # 著作権者と authors.name も更新
./scripts/linux/rename-project.sh my-project "Your Name" you@example.com  # email も更新
```

**macOS**

```bash
./scripts/macos/rename-project.sh my-project
./scripts/macos/rename-project.sh my-project "Your Name"
./scripts/macos/rename-project.sh my-project "Your Name" you@example.com
```

**Windows**

```powershell
./scripts/windows/rename-project.ps1 my-project
./scripts/windows/rename-project.ps1 my-project "Your Name"
./scripts/windows/rename-project.ps1 my-project "Your Name" you@example.com
```

入力は kebab-case のみ受け付けます。`pyproject.toml` の `name` はそのまま使い、Python 識別子はハイフンをアンダースコアに置き換えたものになります。

| 指定する名前 (`pyproject.toml` の `name`) | Python 識別子 (`import` など) |
| ---------------------------------------- | ----------------------------- |
| `my-project`                             | `my_project`                  |
| `my-app`                                 | `my_app`                      |

スクリプトが自動で更新する箇所:

- `pyproject.toml` の `name` と `[project.scripts]` のエントリ
- `src/` 配下のパッケージディレクトリ名
- `tests/` の `import` 文
- `src/*/__init__.py` の doc コメント
- `README.md` のタイトル、構成ツリー、`uv run` 例、パッケージパス
- `scripts/*/run.*` のコンソールスクリプト名
- `.vscode/launch.json` の表示名とモジュール名
- `uv.lock` (`uv lock` で再生成)
- (第 2 引数指定時) `LICENSE` の著作権表記 (年は実行時の西暦) と `authors.name`
- (第 3 引数指定時) `pyproject.toml` の `authors.email`

手動で更新が必要な箇所:

- `pyproject.toml` の `description`, `repository` など
- `README.md` のプロジェクト説明文
- (引数省略時) `LICENSE` と `authors`

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
- **src レイアウト** (`src/python_template/` パッケージ。`__version__` と PEP 561 の `py.typed` を含む)
- **コンソールスクリプト** (`[project.scripts]` → `uv run python-template`)
- **エディタ設定** (`.editorconfig`, `.gitattributes`, `.vscode/` で Ruff 推奨・保存時フォーマット。pytest をテストエクスプローラーで検出。デバッグ開始時に `.venv` が無ければ `uv sync`)

## ライセンス

MIT (利用時に `pyproject.toml` の `authors` や `LICENSE` を適宜変更してください)
