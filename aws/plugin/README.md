# plugin

Kubernetesへエコシステムなどの導入に必要なAWSリソースをterraformにて作成します。
ディレクトリごとに1つのプラグインとして導入に必要なリソースを定義し、plugin/env/dev/variables.tfの定義内容によって各プラグインのリソースの作成可否を制御します。

## Terraform構成

```text
plugin
  │  main.tf      ・・・リソース定義の全量を定義する(全moduleの実行定義)
  │  variables.tf
  │  
  ├─env     ・・・環境毎のディレクトリ。基本的にvariablesに定義する値だけ環境毎に変えることでコントロールする。
  │  ├─dev
  │  │   │  main.tf
  │  │   │  variables.tf　・・・開発用の設定値
  │  └─prod
  │      │  main.tf
  │      │  variables.tf　・・・本番用の設定値
  │                                      
  └─modules　　・・・各種pluginリソースのまとまりでmodule化
      ├─kong-apigateway  ・・・APIGatewayリソースのmodule
      ├─backup           ・・・バックアップ保管用ストレージリソースを作成するmodule。環境削除時もバックアップは残るように独立したプロジェクトで作成。
      ├─init             ・・・このTerraformリソース全体の初期化用のmodule。tfstate管理のS3バケット作成など。
      └─autn             ・・・認証のリソースを作成するmodule

AWS-S3
  │  
  nautible-dev-plugin-tf-ap-northeast-1 ・・・Terraformを管理するためのS3バケット。バージョニング有効。
        │   nautible-dev-plugin.tfstate    ・・・Terraformのtfstate
AWS-Dynamodb
  │  
  └─nautible-dev-plugin-tstate-lock ・・・teffaromのtfstateのlockテーブル
```

※各module配下のファイルは記載を割愛

### 環境構築対象のリソース

「terraform plan」で確認してください

### 環境構築の前に

* AWS環境の環境構築のみサポートしています
* Terraformを利用して環境構築を行います
* TerraformのAWS認証は環境変数「AWS_PROFILE」でプロファイルを利用して実行することを想定しています（Terraformの定義ファイルを編集する事で他の方法でも認証可能ですが、SCMへのコミットミスなどに注意が必要です）

### 環境構築実行環境事前準備

* sh実行可能環境であること
* [Terraform(cli)のインストール](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWSアカウントの作成
* [AWS cliのインストール](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-install.html)
* AWS接続要の[cliプロファイル作成](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-profiles.html)

### 環境構築手順

* AWSの接続プロファイルを環境変数に設定する「export AWS_PROFILE=profile_name」
* tfstate管理用のS3バケットの作成（管理者が一度だけ実行。Terraformで作成するのはアンチパターンですが、nautibleを簡単に試せるようにするため用意しています）
  * plugin/modules/initのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * plugin/modules/initディレクトリで「terraform init」の実行
  * plugin/modules/initディレクトリで「terraform plan」の実行と内容の確認
  * plugin/modules/initディレクトリで「terraform apply」の実行
* AWS環境の構築
  * plugin/env/devのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * plugin/env/devディレクトリで「terraform init」の実行
  * plugin/env/devディレクトリで「terraform plan」の実行と内容の確認
  * plugin/env/devディレクトリで「terraform apply」の実行

※prodの場合はplugin/env/devをprodに読み替えてください。

## バックアップ環境構築手順

terraform destroyによる環境破棄の際にバックアップデータが消えないようにbackupモジュールのみ独立した環境としています。

バックアップ環境の構築手順は[こちら](./modules/backup/README.md)を参照してください。
