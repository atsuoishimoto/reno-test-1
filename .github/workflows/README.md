# GitHub Actions ワークフローの命名規則

## ファイル名: `<役割>-<対象>.yml`

prefix は「いつ・なぜ走るか」（役割）、suffix は「何に対して走るか」（対象）を表す。
ツール名や動作（test / lint / scan など）を prefix にしない。中身のツールは入れ替わるが、
役割は安定するため。同様にトリガー（pr- / nightly- など）も prefix にしない。

| prefix      | 役割                                       | 例                                         |
| ----------- | ------------------------------------------ | ------------------------------------------ |
| `ci-`       | マージ前にコードを検証するゲート（対象別） | `ci-backend.yml`, `ci-gha.yml`             |
| `security-` | リポジトリ横断のセキュリティスキャン       | `security-scan.yml`, `security-codeql-*.yml` |
| `deploy-`   | 環境への反映（suffix は環境名）            | `deploy-development.yml`                   |

prefix の語彙はこの 3 つで閉じる。新しい役割（release など）が必要になったときだけ追加する。

## 新しいチェックの置き場

- 特定の対象（backend / frontend / Dockerfile / workflows）にしか掛からないツール
  → その `ci-<対象>` へ（例: ruff → ci-backend、hadolint → ci-docker、actionlint → ci-gha）
- リポジトリ全体を見るスキャン（secrets・依存脆弱性など） → `security-scan` へ

## workflow name / job name

- workflow の `name:` はファイル名と同じ語で書く（固有名詞・略語以外は小文字）。
  Actions タブのサイドバーは name 順に並ぶため、ファイル名と同じ prefix を先頭に置く
  （例: `ci-backend.yml` → `CI backend`）。
- job の表示名は、単一ツールのジョブはツール名小文字（例: `gitleaks`）、複数ツールを
  束ねたジョブは内容を ` / ` 区切りで列挙する（例: `actionlint / yamlfmt`）。
  PR の checks 欄は「workflow 名 / job 名」で表示されるため、対象の説明は workflow 名に
  任せて job 名は短く保つ。
