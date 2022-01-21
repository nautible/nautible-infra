# nautible-app
アプリケーションの実装要件で必要となるAzureリソースを管理する

## Terraform構成
```
nautible-azure-app
  │  main.tf      ・・・リソース定義の全量を定義する(全moduleの実行定義
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
      ├─product   ・・・商品のリソースのmodule
      ├─order     ・・・注文のリソースのmodule
      ├─stock     ・・・在庫のリソースのmodule
      └─customer  ・・・顧客のリソースのmodule

Azure-StorageAccount
  │
  └─${pjname}terraformsa          ・・・Terraformを管理するためのstorageaccount。
        │   
        └─${pjname}terraformcontainer     ・・・Terraformのtfstateを管理するためのコンテナ
              │
              └─{pjname}app.tfstate     ・・・Terraformのtfstate
```
※各module配下のファイルは記載を割愛

### 環境構築対象のリソース
「terraform plan」で確認してください

### 環境構築の前に
* Terraformを利用して環境構築を行います
* TerraformのAzure認証は事前にaz loginしている事を前提としています
Terraformの定義ファイルを編集する事で他の方法でも認証可能ですが、SCMへのコミットミスなどに注意が必要です

### 環境構築実行環境事前準備
* [Terraform(cli)のインストール](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Azureアカウントの作成
* [Azure cliのインストール](https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli)

### 環境構築手順

* 「az login」を実行してAzureにログインする
* tfstate管理用のstorageaccountの作成（管理者が一度だけ実行。Terraformで作成するのはアンチパターンですが、nautibleを簡単に試せるようにするため用意しています）
  * nautible-azure-app/modules/initのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * nautible-azure-app/modules/initディレクトリで「terraform init」の実行
  * nautible-azure-app/modules/initディレクトリで「terraform plan」の実行と内容の確認
  * nautible-azure-app/modules/initディレクトリで「terraform apply」の実行
* Azure環境の構築
  * nautible-azure-app/env/devのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
  * nautible-azure-app/env/devディレクトリで「terraform init」の実行
  * nautible-azure-app/env/devディレクトリで「terraform plan」の実行と内容の確認
  * nautible-azure-app/env/devディレクトリで「terraform apply」の実行

※prodの場合はnautible/env/devをprodに読み替えてください。
