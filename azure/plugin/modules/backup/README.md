# Veleroバックアップ

## Azureリソース作成

### バックアップ用リソース

バックアップデータを保管するストレージアカウントおよびコンテナ―を作成します。また、VeleroからAzureリソースにアクセスできるようにロールの作成も行います。

作成するリソースは以下の通りです。

- リソースグループ
- ストレージアカウント
  - コンテナー
- アプリケーション
  - サービスプリンシパル
  - ロール

### バックアップリソース構築

- plugin/modules/backup/env/devのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
- plugin/modules/backup/env/devディレクトリで「terraform init」の実行
- plugin/modules/backup/env/devディレクトリで「terraform plan」の実行と内容の確認
- plugin/modules/backup/env/devディレクトリで「terraform apply」の実行

### AzurePortal上でパスワードを作成

1. AzureADを開く
2. アプリケーション＞証明書とシークレット＞クライアントシークレット
3. 新しいクライアントシークレット
4. 任意の期間を指定して作成

作成したらパスワードが生成されるのでコピーしておく。

### クレデンシャルファイル作成

~/.azure/credentials-verero

```bash
AZURE_SUBSCRIPTION_ID=<サブスクリプションID>
AZURE_TENANT_ID=<テナントID> # AzureID＞アプリの登録＞Terraformで登録したアプリを開き確認
AZURE_CLIENT_ID=<クライアントID> # AzureID＞アプリの登録＞Terraformで登録したアプリを開き確認
AZURE_CLIENT_SECRET=<AzurePortal上で作成したパスワード>
AZURE_RESOURCE_GROUP=<AKSが作成するリソースグループ> # AzurePortalでディスクを開き、pvcのリソースグループを確認
AZURE_CLOUD_NAME=AzurePublicCloud
```

## Velero

### Velero CLIの導入

以下から必要なバージョンをダウンロードし、パスを通す。（v1.10.x）

```bash
https://github.com/vmware-tanzu/velero/releases/
```

### Veleroインストール

```bash
velero install \
    --provider azure \
    --image velero/velero:v1.10.0 \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.6.0 \
    --secret-file ~/.azure/credentials-velero \
    --bucket <コンテナ名> \
    --backup-location-config resourceGroup=<リソースグループ名>,storageAccount=<ストレージアカウント名> \
    --snapshot-location-config apiTimeout=5m,resourceGroup=<リソースグループ名>,subscriptionId=<サブスクリプションID>
```

※ --imageおよび--pluginsに指定するバージョンは最新パッチのバージョンにしてください

### バックアップ実行（オンデマンド）

```bash
velero backup create <バックアップ名> --ttl 7200h --wait
```

※ TTLを設定しない場合、デフォルト720hとなる

### リストア実行

```bash
velero create restore --from-backup <バックアップ名> --wait
```

### クリーンアップ

```bash
velero uninstall
```
