# app-ms

マイクロサービスアプリケーション（nautible-puginリポジトリのapp-ms）の実装要件で必要となるAWSリソースを管理する

## Terraform構成

```text
app-ms
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
  └─modules　　・・・各種リソースのまとまりでmodule化
      ├─common    ・・・複数リソースで利用するmodule
      ├─product   ・・・商品のリソースのmodule
      ├─order     ・・・注文のリソースのmodule
      ├─stock     ・・・在庫のリソースのmodule
      ├─init      ・・・このTerraformリソース全体の初期化用のmodule。tfstate管理のS3バケット作成など。
      ├─payment   ・・・決済のリソースのmodule
      └─customer  ・・・顧客のリソースのmodule

AWS-S3
  │  
  └─nautible-dev-app-ms-tf-ap-northeast-1 ・・・Terraformを管理するためのS3バケット。バージョニング有効。
        │   nautible-dev-app-ms.tfstate   ・・・Terraformのtfstate
AWS-Dynamodb
  │  
  └─nautible-dev-app-ms-tfstate-lock
              ・・・teffaromのtfstateのlockテーブル
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
  * app-ms/modules/initのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * app-ms/modules/initディレクトリで「terraform init」の実行
  * app-ms/modules/initディレクトリで「terraform plan」の実行と内容の確認
  * app-ms/modules/initディレクトリで「terraform apply」の実行
* AWS環境の構築
  * app-ms/env/devのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * app-ms/env/devディレクトリで「terraform init」の実行
  * app-ms/env/devディレクトリで「terraform plan」の実行と内容の確認
  * app-ms/env/devディレクトリで「terraform apply」の実行

※prodの場合はapp-ms/env/devをprodに読み替えてください。
