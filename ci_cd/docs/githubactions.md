# GithubActions

Github上の何らかのアクションをトリガーにワークフローを実行する機能。

## 環境変数

Githubリポジトリのシークレットに以下の定義を登録

- DEPLOY_TARGET : (aws/azure)


### PersonalAccessToken

事前にPersonalAccessTokenを発行しアプリケーションリポジトリ（もしくはOrgnization）のシークレットに変数名PATで登録しておく

## ワークフローファイル

リポジトリの.github/workflows/配下にCI設定を記載したYAMLファイルを配置する。

## CI設定

[コード全体のサンプル](https://github.com/nautible/nautible-app-ms-customer/blob/main/.github/workflows/maven.yml)

### トリガー設定

onで指定する。以下はmainブランチへのプッシュをトリガーとする例

```yaml
on:
  push:
    branches: [ main ]
```

[ワークフローのトリガー 一覧](https://docs.github.com/ja/actions/using-workflows/events-that-trigger-workflows)

### ワークフローの実行

ワークフローの実行はGithubや各クラウドベンダーから提供されるActionsファイルを利用して実施する。（再利用されないような固有の処理はスクリプトを記述する）

[GithubActions Marketplace](https://github.com/marketplace?type=actions)

### リポジトリのチェックアウト  

actions/checkout@v2を利用する。
他リポジトリ（下記例ではmanifestのリポジトリ）をチェックアウトする場合はwithでリポジトリを指定する。

```yaml
    - name: Checkout repo
      uses: actions/checkout@v2
    - name: Checkout manifest repo
      uses: actions/checkout@v2
      with:
        repository: nautible/nautible-app-ms-customer-manifest
        path: nautible-app-ms-customer-manifest
```

### JDKのセットアップ

actions/setup-java@v1を利用する。

```yaml
    - name: Set up JDK 11
      uses: actions/setup-java@v1
      with:
        java-version: 11
```

### キャッシュ

actions/cache@v2を利用する。

```yaml
    - name: Cache Maven packages
      uses: actions/cache@v2
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: ${{ runner.os }}-m2
```

### AWSへの接続認証（OIDC）

aws-actions/configure-aws-credentials@v1を利用する。

```yaml
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
```

### Azureへの接続認証

azure/login@v1を利用する。

```yaml
    - name: Login via Azure CLI
      id: login-acr
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
```

### ECRへログイン（AWS）

aws-actions/amazon-ecr-login@v1

```yaml
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
```

### ACRへログイン（Azure）

azure/docker-login@v1を利用する。

```yaml
    - name: Login Azure Docker
      id: login-azure-docker
      uses: azure/docker-login@v1
```

### イメージの作成～DockerPush

イメージの作成及びDockerPushについては、スクリプトを作成する。

```yaml
    - name: Customer Build, tag, and push image to Amazon ECR
      id: build-image-service
      env:
        DOCKER_BUILDKIT: 1
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: nautible-app-ms-customer
      run: |
        cd $GITHUB_WORKSPACE
        docker build --cache-from=$ECR_REGISTRY/$ECR_REPOSITORY:latest --build-arg BUILDKIT_INLINE_CACHE=1 -t $ECR_REGISTRY/$ECR_REPOSITORY:latest -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG -f ./src/main/docker/Dockerfile.fast-jar .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
```

### プルリクエスト作成

スクリプトを作成する。手順は以下の通り。

- プルリクエスト用に新規にブランチを作成し、Deployment内のイメージファイルのタグをsedで更新
- APIでプルリクエスト送信

```yaml
    - name: pull request
      id: pull-request
      env:
        token: ${{ secrets.PAT }}
        tag: update-image-feature
      run: |
        cd $GITHUB_WORKSPACE/nautible-app-ms-customer-manifest
        git checkout -b $tag
        sed -i 's/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-ms-customer:\(.*\)/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-ms-customer:'$IMAGE_TAG'/' ./base/customer-deploy.yaml 
        git config user.name github-actions
        git config user.email github-actions@github.com
        git add .
        git commit -m "update manifest"
        git push --set-upstream origin $tag
        curl -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $token" "https://api.github.com/repos/nautible/nautible-app-ms-customer-manifest/pulls" -d '{"title": "new image deploy request", "head": "nautible:'$tag'", "base": "main"}'
```

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
