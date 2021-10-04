# GithubActions

[公式ドキュメント](https://docs.github.com/ja/actions)

## 環境変数

シークレットに以下の定義を登録

- AWS_ACCOUNT_ID : アカウントID
- AWS_ACCESS_KEY_ID  : アクセスキー
- AWS_SECRET_ACCESS_KEY  : シークレットアクセスキー

※ シークレットを持たずに運用することも可能になっている[（参考）](https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html)

## 利用手順

リポジトリの.github/workflows/配下にCI設定を記載したYAMLファイルを配置する。

## CI設定

Java（Quarkus）アプリケーションをビルドおよびコンテナ化し、プルリクエストを生成するまでの設定例。
（アプリケーションリポジトリをnautible-app-customer、マニフェストリポジトリをnautible-app-customer-manifestとした場合の例）

[コード全体のサンプル](https://github.com/nautible/nautible-app-customer/blob/main/.github/workflows/maven.yml)

### mainブランチへのプッシュをトリガーとする

```
on:
  push:
    branches: [ main ]
```

### リポジトリのチェックアウト  

```
    - name: Checkout repo
      uses: actions/checkout@v2
    - name: Checkout manifest repo
      uses: actions/checkout@v2
      with:
        repository: nautible/nautible-app-customer-manifest
        path: nautible-app-customer-manifest
```

### JDKのセットアップ

```
    - name: Set up JDK 11
      uses: actions/setup-java@v1
      with:
        java-version: 11
```

### Mavenビルド

```
    - name: Cache Maven packages
      uses: actions/cache@v2
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: ${{ runner.os }}-m2
    - name: Build with Maven
      run: mvn -B package --file pom.xml -Dquarkus.package.type=fast-jar
```

### ECRへプッシュ

- ECRへログイン
- Dockerイメージを作成し、ECRへプッシュ（latestおよびタグ指定）

```
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-1
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    - name: Customer Build, tag, and push image to Amazon ECR
      id: build-image-service
      env:
        DOCKER_BUILDKIT: 1
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: nautible-app-customer
      run: |
        cd $GITHUB_WORKSPACE
        docker build --cache-from=$ECR_REGISTRY/$ECR_REPOSITORY:latest --build-arg BUILDKIT_INLINE_CACHE=1 -t $ECR_REGISTRY/$ECR_REPOSITORY:latest -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG -f ./src/main/docker/Dockerfile.fast-jar .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
```

### プルリクエスト作成

- プルリクエスト用に新規にブランチを作成し、Deployment内のイメージファイルのタグをsedで更新
- APIでプルリクエスト送信

```
    - name: pull request
      id: pull-request
      env:
        tag: update-image-feature
      run: |
        cd $GITHUB_WORKSPACE/nautible-app-customer-manifest
        git checkout -b $tag
        sed -i 's/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-customer:\(.*\)/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-customer:'$IMAGE_TAG'/' ./base/customer-deploy.yaml 
        git config user.name github-actions
        git config user.email github-actions@github.com
        git add .
        git commit -m "update manifest"
        git push --set-upstream origin $tag
        curl -X POST -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/nautible/nautible-app-customer-manifest/pulls" -d '{"title": "new image deploy request", "head": "nautible:'$tag'", "base": "main"}'
```

## プライベートリポジトリで運用する場合

プライベートリポジトリで運用する場合は、マニフェストリポジトリへのアクセスにトークンが必要になる。

事前に変数名PATでPersonalAccessTokenをnautible/nautible-app-customerのシークレットに登録しておき、下記のようにトークンを利用してマニフェストリポジトリにアクセスするように変更する。

### リポジトリのチェックアウト

```
    - name: Checkout repo
      uses: actions/checkout@v2
    - name: Checkout manifest repo
      uses: actions/checkout@v2
      with:
        repository: nautible/nautible-app-customer-manifest
        path: nautible-app-customer-manifest
+       token: ${{ secrets.PAT }}
```

### プルリクエスト作成

```
    - name: pull request
      id: pull-request
      env:
+       token: ${{ secrets.PAT }}
        tag: update-image-feature
      run: |
        cd $GITHUB_WORKSPACE/nautible-app-customer-manifest
        git checkout -b $tag
        sed -i 's/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-customer:\(.*\)/image: secret.AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com\/nautible-app-customer:'$IMAGE_TAG'/' ./base/customer-deploy.yaml 
        git config user.name github-actions
        git config user.email github-actions@github.com
        git add .
        git commit -m "update manifest"
        git push --set-upstream origin $tag
-       curl -X POST -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/nautible/nautible-app-customer-manifest/pulls" -d '{"title": "new image deploy request", "head": "nautible:'$tag'", "base": "main"}'
+       curl -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $token" "https://api.github.com/repos/nautible/nautible-app-customer-manifest/pulls" -d '{"title": "new image deploy request", "head": "nautible:'$tag'", "base": "main"}'
```
