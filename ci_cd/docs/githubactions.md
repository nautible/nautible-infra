# GithubActions

GithubActionsはGithubを利用していれば特に導入などはなく利用できる。

料金や無償枠等については[こちら](https://docs.github.com/ja/billing/managing-billing-for-github-actions/about-billing-for-github-actions)を参照。

## PersonalAccessToken

Github画面右上のユーザーアイコン→Settings→Developer SettingからPersonalAccessTokenを作成する。（権限はrepoを与えておく）


## 環境変数

Githubリポジトリ（もしくはOrgnization）のシークレットに以下の定義を登録

- PAT : 上記で作成したPersonalAccessToken
- DEPLOY_TARGET : (aws/azure/gcp)

## ワークフローファイル

各アプリケーションリポジトリの.github/workflows/配下にCI設定を記載したYAMLファイルを配置する。

## CI設定

### トリガー

mainブランチへのプッシュをトリガーとする。

```yaml
on:
  push:
    branches: [ main ]
```

[その他ワークフローのトリガー一覧](https://docs.github.com/ja/actions/using-workflows/events-that-trigger-workflows)

### ワークフローで使用するActions

ワークフローの実行はGithubや各クラウドベンダーから提供されるActionsファイルを利用して実施する。（再利用されないような固有の処理はスクリプトを記述する）

[GithubActions Marketplace](https://github.com/marketplace?type=actions)

|Actions|用途|備考|
|:--|:--|:--|
|actions/checkout@v2|Githubリポジトリのチェックアウト||
|actions/setup-java@v1|Javaの導入|Javaプロジェクトのみで必要|
|actions/cache@v2|キャッシュ設定|Javaプロジェクトのみ使用（Mavenのキャッシュ）|
|aws-actions/configure-aws-credentials@v1|AWS認証|イメージのプッシュ先がAWSの場合のみ必要|
|azure/login@v1|Azure認証|イメージのプッシュ先がAzureの場合のみ必要|
|azure/docker-login@v1|ACRログイン|イメージのプッシュ先がAzureの場合のみ必要|

### ワークフロー

以下の手順でCIを実行する。

|No|処理|備考|
|:--|:--|:--|
|1|コードリポジトリをチェックアウト||
|2|マニフェストリポジトリをチェックアウト||
|3|JDK導入|Javaプロジェクトの場合のみ|
|4|Mavenのキャッシュ設定|Javaプロジェクトの場合のみ|
|5|ビルド（Jarファイル作成）|Javaの場合のみ（Goはdocker build内でバイナリを作成する）|
|6|AWSログイン|AWSの場合のみ|
|6´|Azureログイン|Azureの場合のみ|
|7|ECRログイン|AWSの場合のみ|
|7´|ACRログイン|Azureの場合のみ|
|8|DockerBuild & DockerPush||
|9|プルリクエスト作成||

[コード全体のサンプル（Java）](https://github.com/nautible/nautible-app-ms-customer/blob/main/.github/workflows/maven.yml)

[コード全体のサンプル（Go）](https://github.com/nautible/nautible-app-ms-payment/blob/main/.github/workflows/build-payment.yml)

## プライベートリポジトリで運用する場合

プライベートリポジトリで運用する場合はマニフェストリポジトリのCloneにトークンが必要になる。

```yaml
    - name: Checkout repo
      uses: actions/checkout@v2
    - name: Checkout manifest repo
      uses: actions/checkout@v2
      with:
        repository: nautible/nautible-app-ms-customer-manifest
        path: nautible-app-ms-customer-manifest
+       token: ${{ secrets.PAT }}
```

## 参考

[公式ドキュメント](https://docs.github.com/ja/actions)
