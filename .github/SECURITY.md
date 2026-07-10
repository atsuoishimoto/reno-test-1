# セキュリティポリシー

## 脆弱性の報告

本リポジトリのセキュリティ脆弱性を発見した場合は、**公開 Issue を作成せず**、
GitHub の Private Vulnerability Reporting を通じて非公開で報告してください。

- リポジトリの **Security** タブ →
  **「Report a vulnerability」** から報告できます。
- 報告には可能な範囲で以下を含めてください:
  - 影響を受ける箇所（ファイル / エンドポイント / 機能）
  - 再現手順または PoC
  - 想定される影響範囲

メンテナが内容を確認し、修正方針と公開時期について非公開で連絡します。
社内の正規セキュリティ報告窓口がある場合は、そちらも併せてご利用ください。

## サポート対象

セキュリティ修正は `main` ブランチ（および本番デプロイ中のリビジョン）に対して提供します。

## 自動セキュリティ対策

本リポジトリでは CI で以下を継続的に実行しています:

- **CodeQL** — コードの静的解析 (SAST)
- **gitleaks** — シークレットの混入検出
- **OSV-Scanner** — 依存ライブラリ (uv.lock / pnpm-lock.yaml) の既知 CVE 検出
- **dependency-review** — PR が持ち込む脆弱依存のブロック
- **Trivy** — コンテナイメージ (OS 層) の既知 CVE 検出
- **zizmor / actionlint / hadolint** — GitHub Actions / Dockerfile の監査・lint
- **Renovate** — 依存関係の継続的な更新
