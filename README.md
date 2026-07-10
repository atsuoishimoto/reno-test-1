# reno_test_1

TEMPLATE: アプリケーションの簡単な説明を記載

# Description

TEMPLATE: このアプリケーションの目的・解決する課題を記載


# Documents

TEMPLATE: 以下について記載

* アプリケーションのアーキテクチャ図(DBや外部APIとの繋がりなど)
* 仕様・デザイン
* ディレクトリ構造
* 運用体制・手順



## 実行方法

```
uv sync

# (必要に応じて)
uv run task migrate  # DBテーブル作成
uv run task createsuperuser  # 管理ユーザ作成

# webサーバ起動
uv run task runserver  # port8000で起動
```

docker を利用しても起動出来ます。 http://localhost:8000/ でアクセス。

```
docker compose up
```

* 開発・本番ではアプリの前段にNginxがプロキシとして用意されています
* `log-es` へのアプリケーション固有のアクションログ送信方法: TODO
* 必要に応じてdjangoの `--settings` オプションを指定してください
    * 手元開発: `reno_test_1.settings.local`
    * 開発: `reno_test_1.settings.development`
    * 本番: `reno_test_1.settings.production`

データベースとしてMySQLを利用する場合は、次のコマンドで起動してください。

```
docker compose -f docker-compose.mysql.yml up
```


## Test

GitHub Actionsで走るテストは以下のコマンドで手元でも確認できます。

```
uv run tox
```

事前に以下のコマンドでコードを整形して下さい。
```
uv run task format
```

以下のコマンドはより強力なformatです。場合によっては破壊的変更となるのでご注意ください
```
uv run task unsafe-format
```

## Deploy

* GitHub ActionsによりAWS環境へ自動的にデプロイされます。
    * main: 開発環境
    * deployment/production: 本番環境


## ひな形リポジトリの更新を反映する

このプロジェクトはCookiecutterによる[ひな形リポジトリ](https://github.com/Nikkei/ds-ecs-django-project-template)から生成されています。ベースリビジョンは `./cookiepatcher.json` に記録されています。

ひな形リポジトリの更新を反映する作業はClaude codeなどのAIエージェントを利用できます。`prompts/SYNC_TEMPLATE.md` を作業手順としてClaude CodeなどのAIエージェントに与えてください。

```
prompts/SYNC_TEMPLATE.md の手順に従って更新を反映してください
```

`prompts/SYNC_TEMPLATE.md` には以下が含まれます。

* ひな形との差分確認手順
* Python・依存パッケージ・ruff・Django settings・GitHub Actions・Dockerfile などの反映ルール
* プロジェクト側の事情を優先するなどの判断ルール
* 作業後の `cookiepatcher.json` 更新およびテスト実行手順
