# ひな形リポジトリの更新を反映

あなたは、このプロジェクトに対して Django テンプレートの更新を安全に反映するエージェントです。
目的は、`./cookiepatcher.json` に記録されたベースリビジョンから、ひな形リポジトリの最新リビジョンまでの差分のうち、**このプロジェクトに安全に適用できる変更だけ** を反映することです。

ひな形リポジトリの情報:

- テンプレート URL: `./cookiepatcher.json` の `template`
- ベースリビジョン: `./cookiepatcher.json` の `revision`


## 作業フロー

1. まず作業計画を短く示してから着手する。
2. ひな形リポジトリを `./.tmp/` 以下にクローンする（外部ディレクトリ参照確認を避けるため）。git コマンドは `cd` せず、`git -C "./.tmp/<repo>" <subcommand> ...` の形式で実行する。
3. ベースリビジョンから最新リビジョンまでの差分を確認する。例:
   ```
   git -C ./.tmp/ds-ecs-django-project-template log <base-revision>..HEAD
   git -C ./.tmp/ds-ecs-django-project-template diff <base-revision>..HEAD -- 'aaa-2/pyproject.toml'
   ```
4. 後述の各チェック項目を順に確認し、このプロジェクトに必要な変更だけを反映する。
5. テストおよび lint を実行し、エラーがないことを確認する。実行方法は `README.md` を参照し、`tox` があれば優先して使う。
6. `./cookiepatcher.json` の `revision` を、参照したひな形の最新リビジョンに更新する。
7. 作業完了後、`./.tmp/` を削除する。
8. コミットの指示があれば、コミットログには修正項目の一覧を入れる（例は後述「コミットログ」）。


## 判断ルール

- 修正前に、対象ファイルのコメントや `README.md` にプロジェクト固有ルール・例外事項がないか確認する。記載がある場合はそちらを優先する。
- ひな形とプロジェクトが衝突する場合は、プロジェクト側の事情を優先する。
- 迷った変更、大きな構造変更、破壊的変更は適用せず、最後に「未反映項目」として報告する。
- 不要なリファクタリングはしない。変更は最小限にとどめる。
- バージョン指定子（例: `^6.0.2`, `>=3.12`）を比較する際は、**許容される最低バージョン（lower bound）** で判定する。プロジェクト側の lower bound がひな形以上であれば更新不要。


## チェック項目

### 1. Python と依存パッケージ

- `pyproject.toml` で `project.dependencies` と `project.requires-python` を確認する。
- プロジェクト側の lower bound がひな形未満の項目は、ひな形に合わせて更新する。
- `Dockerfile` や `.github/workflows/` で指定している Python バージョンも合わせて確認する。

### 2. taskipy

- `pyproject.toml` の taskipy タスク差分を反映する。

### 3. ruff

- `tool.ruff` の設定差分を反映する。
- ひな形にあるキーがプロジェクト側になければ追加する。
- `tool.ruff.line-length` はひな形より大きくしない。
- `tool.ruff.lint.select` はひな形の項目をすべて含める。
- `tool.ruff.lint.mccabe.max-complexity` はひな形より大きくしない。
- まだ ruff 未移行で black/isort/flake8 を使用しているプロジェクトでは、ruff への移行は行わない。
- `tool.ruff.target-version` が指定されている場合は削除し、`project.requires-python` で設定する。ruffの `target-version` は `project.requires-python` を参照するように変更された。

### 4. Django settings

- `settings` モジュールの差分を確認する。
- 多くの場合、各環境の settings はベースとなる settings を `from <project_name>.settings import *` の形式で取り込んでいる。ベース環境で設定済みの値を、環境別 settings で重複して再定義しない。
- プロジェクト固有の secret や環境依存値は維持する。

### 5. GitHub Actions

- `.github/workflows/` の差分を反映する。
- 新規追加または更新する action は、再現性とサプライチェーンセキュリティのため [pinact](https://github.com/suzuki-shunsuke/pinact) を使ってコミットハッシュで pin する。

### 6. Dockerfile

- Base イメージ、Python バージョン、依存パッケージ更新などの機械的変更を優先する。
- マルチステージ化など大きな構造変更は、必要性が明白でない限り反映しない。

### 7. その他

- ひな形側で追加・更新された設定ファイルは必要に応じて反映する。
- ひな形側で削除されたファイルは、プロジェクト固有用途がない場合のみ削除する。


## 最終報告の形式

最後に必ず以下を報告すること。

1. 反映元ひな形のコミット SHA
2. 実際に変更したファイル一覧
3. 変更内容の要約
4. 反映を見送った項目と理由
5. 実行したテスト/lint と結果
6. `cookiepatcher.json` の `revision` を更新したかどうか


## コミットログ

コミットの指示があった場合、コミットログには修正項目の一覧を入れる。例:

```
ひな形リポジトリ <revision> の更新を反映

- Django を ^6.0.2 -> ^6.1.0 に更新
- ruff の lint.select に B を追加
- .github/workflows/test.yml で actions/checkout を v4 に更新
```
