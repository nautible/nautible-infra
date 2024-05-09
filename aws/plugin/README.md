# plugin

Kubernetes へエコシステムなどの導入に必要な AWS リソースを terraform にて作成します。
ディレクトリごとに 1 つのプラグインとして導入に必要なリソースを定義し、plugin/env/dev/variables.tf の定義内容によって各プラグインのリソースの作成可否を制御します。

## Terraform 構成

```text
plugin
  │  main.tf      ・・・リソース定義の全量を定義する(全moduleの実行定義)
  │  variables.tf
  │
  ├─env     ・・・環境毎のディレクトリ。基本的にvariablesに定義する値だけ環境毎に変えることでコントロールする。
  │  ├─dev
  │  │   │  main.tf
  │  │   │  variables.tf　・・・開発用の設定値
  │  └─prod (未作成)
  │      │  main.tf
  │      │  variables.tf　・・・本番用の設定値
  │
  └─modules　　・・・各種pluginリソースのまとまりでmodule化
      ├─auth             ・・・認証のリソースを作成するmodule
      ├─backup           ・・・バックアップ保管用ストレージリソースを作成するmodule。環境削除時もバックアップは残るように独立したプロジェクトで作成。
      ├─init             ・・・このTerraformリソース全体の初期化用のmodule。tfstate管理のS3バケット作成など。
      ├─kong-apigateway  ・・・APIGatewayリソースのmodule
      └─observation      ・・・オブザーバビリティで使用するストレージ（S3）とアクセス権（IRSA）を作成するmodule

AWS-S3
  │
  nautible-dev-plugin-tf-ap-northeast-1 ・・・Terraformを管理するためのS3バケット。バージョニング有効。
        │   nautible-dev-plugin.tfstate    ・・・Terraformのtfstate
AWS-Dynamodb
  │
  └─nautible-dev-plugin-tstate-lock ・・・teffaromのtfstateのlockテーブル
```

※各 module 配下のファイルは記載を割愛

### 環境構築対象のリソース

「terraform plan」で確認してください

### 環境構築の前に

- AWS 環境の環境構築のみサポートしています
- Terraform を利用して環境構築を行います
- Terraform の AWS 認証は環境変数「AWS_PROFILE」でプロファイルを利用して実行することを想定しています（Terraform の定義ファイルを編集する事で他の方法でも認証可能ですが、SCM へのコミットミスなどに注意が必要です）

### 環境構築実行環境事前準備

- sh 実行可能環境であること
- [Terraform(cli)のインストール](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS アカウントの作成
- [AWS cli のインストール](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-install.html)
- AWS 接続要の[cli プロファイル作成](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-profiles.html)

### 環境構築手順

- AWS の接続プロファイルを環境変数に設定する「export AWS_PROFILE=profile_name」
- tfstate 管理用の S3 バケットの作成（管理者が一度だけ実行。Terraform で作成するのはアンチパターンですが、nautible を簡単に試せるようにするため用意しています）
  - plugin/modules/init の main.tf と variables.tf をファイル内のコメントを参考に用途にあわせて修正
  - plugin/modules/init ディレクトリで「terraform init」の実行
  - plugin/modules/init ディレクトリで「terraform plan」の実行と内容の確認
  - plugin/modules/init ディレクトリで「terraform apply」の実行
- AWS 環境の構築
  - plugin/env/dev の main.tf と variables.tf をファイル内のコメントを参考に用途にあわせて修正
  - plugin/env/dev ディレクトリで「terraform init」の実行
  - plugin/env/dev ディレクトリで「terraform plan」の実行と内容の確認
  - plugin/env/dev ディレクトリで「terraform apply」の実行

※prod の場合は plugin/env/dev を prod に読み替えてください。

## バックアップ環境構築手順

terraform destroy による環境破棄の際にバックアップデータが消えないように backup モジュールのみ独立した環境としています。

バックアップ環境の構築手順は[こちら](./modules/backup/README.md)を参照してください。
