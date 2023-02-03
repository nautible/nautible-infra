# Veleroバックアップ

## Azureリソース作成

### 本ディレクトリ上でTerraformを実行し、以下のものを作成

- リソースグループ
- ストレージアカウント
  - コンテナー
- アプリケーション
  - サービスプリンシパル
  - ロール

```bash
terraform init
terraform plan
terraform apply
```

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
    --bucket velero \
    --backup-location-config resourceGroup=nautibledevbackup,storageAccount=nautibledevbackup \
    --snapshot-location-config apiTimeout=5m,resourceGroup=nautibledevbackup,subscriptionId=<サブスクリプションID>
```

※ --imageおよび--pluginsに指定するバージョンは最新パッチのバージョンにしてください

### バックアップ実行（オンデマンド）

```bash
velero backup create <バックアップ名> --wait
```

### リストア実行

```bash
velero create restore --from-backup <バックアップ名> --wait
```

### クリーンアップ

```bash
velero uninstall
```
