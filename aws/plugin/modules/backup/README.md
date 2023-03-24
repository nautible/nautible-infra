# Veleroバックアップ

## AWSリソース作成

### バックアップ用リソース

バックアップデータを保管するS3バケットを作成します。また、VeleroからAWSリソースにアクセスできるようにポリシーの作成も行います。（ポリシーはEKSのNodeロールに紐づけることでアクセスできるように設定します）

作成するリソースは以下の通りです。

- S3バケット
  - 暗号化設定
  - バージョニング設定
  - パブリックブロック設定
- ポリシー設定（Nodeロールに紐づけ）

### バックアップリソース構築

- plugin/modules/backup/env/devのmain.tfとvariables.tfをファイル内のコメントを参考に用途にあわせて修正
- plugin/modules/backup/env/devディレクトリで「terraform init」の実行
- plugin/modules/backup/env/devディレクトリで「terraform plan」の実行と内容の確認
- plugin/modules/backup/env/devディレクトリで「terraform apply」の実行

## Velero

### Velero CLIの導入

以下から必要なバージョンをダウンロードし、パスを通す。（v1.10.x）

```bash
https://github.com/vmware-tanzu/velero/releases/
```

### Veleroインストール

```bash
velero install \
    --provider aws \
    --image velero/velero:v1.9.2 \
    --plugins velero/velero-plugin-for-aws:v1.5.1 \
    --bucket <バケット名> \
    --secret-file .aws/credentials \
    --backup-location-config region=<リージョン名> \
    --snapshot-location-config region=<リージョン名>
```

※ --imageおよび--pluginsに指定するバージョンは最新パッチのバージョンにしてください

### バックアップ実行（オンデマンド）

```bash
velero backup create backup_20230324 --ttl 7200h --wait
```

※ TTLを設定しない場合、デフォルト720hとなる

### バックアップ履歴の確認

```bash
velero backup get

NAME              STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
backup-20230324   Completed   0        2          2023-03-24 15:06:25 +0900 JST   299d      default            <none>
```

### リストア実行

```bash
velero create restore --from-backup <バックアップ名> --wait
```

### クリーンアップ

```bash
velero uninstall
```
