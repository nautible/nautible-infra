# 秘匿情報管理

nautibleアプリケーションを稼働させるために必要な秘匿情報を準備する。

秘匿情報はクラウドのキーマネージャー上で管理し、kubernetes-external-secretsを利用してアクセスできる環境を提供する。

## nautibleで利用する秘匿情報

nautibleで利用する秘匿情報の一覧は下記となる。利用するクラウドのキーマネージャー上へ登録する。

### AWS(SystemsManager ParameterStore) 

|キー|内容|備考|
|---|---|---|
|/nautible-app/product/db/user|商品DB（RDS）接続ユーザ||
|/nautible-app/product/db/password|商品DB（RDS）接続パスワード||
|/nautible-infra/github/user|Githubアクセスユーザ|Privateリポジトリにアクセスする場合のみ|
|/nautible-infra/github/token|GithubPersonalAccessToken|Privateリポジトリにアクセスする場合のみ|

### Azure(KeyVault)

|キー|内容|備考|
|---|---|---|
|nautible-app-product-db-user|商品DB（RDS）接続ユーザ||
|nautible-app-product-db-password|商品DB（RDS）接続パスワード||
|nautible-app-cosmosdb-user|CosmosDB接続ユーザ||
|nautible-app-cosmosdb-password|CosmosDB接続パスワード||
|nautible-infra-github-user|Githubアクセスユーザ|Privateリポジトリにアクセスする場合のみ|
|nautible-infra-github-token|GithubPersonalAccessToken|Privateリポジトリにアクセスする場合のみ|


## Kubernetesからのアクセス方法

Kubernetes上のアプリケーションからクラウドのキーマネージャーに登録されている秘匿情報を参照するために、kubernetes-external-secretsを利用する。

## kubernetes-external-secrets アーキテクチャ

![Architecture](https://github.com/external-secrets/kubernetes-external-secrets/raw/master/architecture.png)

出典：[kubernetes-external-secrets公式Github](https://github.com/external-secrets/kubernetes-external-secrets)

### サポートしているバックエンド(2021/10/01時点)

- AWS： SecretsManager、SystemsManagerパラメータストア
- Azure： KeyVault
- GCP： Secret Manager
- Hashicorp： Vault
- AlibabaCloud： KMS Secret Manager
- Akeyless： Vault
- IBM： Cloud Secrets Manager

## 利用手順

### kubernetes-external-secrets（コントローラ）のデプロイ

[CI/CDの導入手順](https://github.com/nautible/nautible-infra/tree/main/ArgoCD)を参照。エコシステムを定義したApplicationリソースをデプロイするとkubernetes-external-secretsのコントローラも含まれている。


### （参考）kubernetes-external-secretsデプロイ時の環境変数変更について

kubernetes-external-secretsデプロイ用application.yamlを編集する。

#### デフォルトの設定項目

AWS

|設定項目|設定値|
|---|---|
|env.AWS_REGION|ap-northeast-1|

Azure

|設定項目|設定値|
|---|---|
|なし||

また、他デフォルトから変更可能な変数は[external-secretsのHelmChart](https://github.com/external-secrets/kubernetes-external-secrets)のcharts/kubernetes-external-secrets/values.yamlを参照



※Azure Key Vaultを利用する場合は、Key Vaultへアクセスするためのアプリケーションを登録し、アプリケーションのSecrets等の[パラメータを設定する](https://github.com/external-secrets/kubernetes-external-secrets#azure-key-vault)必要があります。アプリケーションの登録については後述します。

## シークレットの登録（AWS）

### 1. パラメータストアへの秘匿情報登録

AWSコンソールからSystemManager→パラメータストアを開き、秘匿情報を登録する

```
/nautible-app/product/db/user
/nautible-app/product/db/password
```

### 2. EKSからSystemManagerへのアクセス権限を設定

nautibleではAWSインフラ情報をTerraformで管理しているため、Terraformの設定にポリシー追加の記述を追記する  
[Terraform ポリシー設定箇所](https://github.com/nautible/nautible-infra/blob/main/aws/terraform/nautible-aws-app/modules/common/main.tf)

手動で設定する例は下記（nautible-で始まるパラメータへのアクセスを許可する例）

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/nautible-*"
    }
  ]
}
```

※ResourceのリージョンとアカウントID部は各環境に合わせて変更

上記ポリシーを作成したら、EKSで利用しているEC2のロールにアタッチする。

### 3. AWSでのシークレットの定義

シークレットの定義はkustomizeとArgoCDで管理している  
AWSの定義を追加する手順は以下の通り

なお、nautibleがデフォルトで用意しているシークレットは[こちら](https://github.com/nautible/nautible-infra/tree/main/ArgoCD/secrets/overlays/aws)を参照  

#### 3.1. シークレットの定義ファイルを作成

```
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: secret-nautible-app-product-db
  namespace: nautible-app
spec:
  backendType: systemManager
  data:
    - key: /nautible-app/product/db/user      # SystemManager key
      name: DATABASE_USER                     # Deployment name
    - key: /nautible-app/product/db/password  # SystemManager key
      name: DATABASE_PW                       # Deployment name
```

注）ArgoCD v2.0ではYAMLに日本語コメントがあるとデプロイに失敗ので、コメントを記載する際は英字で記載する

#### 3.2. kustomization.yamlに定義を追加

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - product-db.yaml
```

#### 3.3. application.yamlをArgoCDに登録

ArgoCD/secrets/overlays/aws/application.yamlをArgoCDに登録して管理対象のシークレットを生成する

```
$ kubectl apply -f application.yaml
```

ArgoCD上でシークレットが作成されていることを確認

![external-secret](https://user-images.githubusercontent.com/29446925/98647980-ffd30800-2378-11eb-8e48-05141cc0a7cc.png)

## シークレットの登録（Azure）

### 1. KeyVaultへの秘匿情報登録

Azureポータルからキーコンテナ＞シークレットを開き、秘匿情報を登録する

```
nautible-app-product-db--user
nautible-app-product-db-password
nautible-app-cosmosdb-user
nautible-app-cosmosdb-password
```

### 2. AKSからKeyVaultへのアクセス権限について

ExternalSecretsのAzure KeyVaultのアクセスはAzureのアプリケーションを登録し、アプリケーションのSecretsを利用してアクセスします。
nautibleではAzureインフラ情報やAzureのアプリケーションをTerraformで管理しているため、Terraformの設定でアプリケーションの登録とKeyVaultへのアクセス権を定義しています。 
[Terraform ポリシー設定箇所](https://github.com/nautible/nautible-infra/blob/main/azure/terraform/nautible-azure-platform/modules/app/main.tf)


```
resource "azuread_application" "app" {
  display_name = "${var.pjname}app"
  owners       = [data.azuread_client_config.current.object_id]
  api {
  }

  required_resource_access {
    resource_app_id = data.azuread_service_principal.key_vault.application_id
    dynamic "resource_access" {
      for_each = data.azuread_service_principal.key_vault.oauth2_permission_scopes
      content {
        id   = resource_access.value.id
        type = "Scope"
      }
    }
  }
}
```


### 3. Azureでのシークレットの定義

シークレットの定義はkustomizeとArgoCDで管理している  
Azureの定義を追加する手順は以下の通り

なお、nautibleがデフォルトで用意しているシークレットは[こちら](https://github.com/nautible/nautible-infra/tree/main/ArgoCD/secrets/overlays/azure)を参照。  
nautibleの[サンプル](https://github.com/nautible/nautible-infra/tree/main/ArgoCD/secrets/overlays/azure)を参考にしてください。

#### 3.1. シークレットの定義ファイルを作成

```
apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: secret-nautible-app-cosmosdb
  namespace: nautible-app
spec:
  backendType: azureKeyVault
  keyVaultName: nautibledevkeyvault
  data:
    - key: nautible-app-cosmosdb-user      # Key Vault key
      name: DATABASE_USER                  # Deployment name
    - key: nautible-app-cosmosdb-password  # Key Vault key
      name: DATABASE_PW                    # Deployment name
```

注）ArgoCD v2.0ではYAMLに日本語コメントがあるとデプロイに失敗ので、コメントを記載する際は英字で記載する

#### 3.2. kustomization.yamlに定義を追加

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - cosmosdb.yaml
```

※nautible-app-product-db--user,nautible-app-product-db-passwordも同様の手順で作成する

#### 3.3. application.yamlをArgoCDに登録

ArgoCD/secrets/overlays/azure/application.yamlをArgoCDに登録して管理対象のシークレットを生成する

```
$ kubectl apply -f application.yaml
```

ArgoCD上でシークレットが作成されていることを確認

![external-secret](https://user-images.githubusercontent.com/29446925/98647980-ffd30800-2378-11eb-8e48-05141cc0a7cc.png)



## アプリケーションからの利用

アプリケーションからの利用は通常のsecret利用と同様となる

Deploymentでシークレットを環境変数として読み込む例

```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nautible-app-product-deployment
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: nautible-app-product
          imagePullPolicy: Always
          env:
            - name: DB_HOST
              value: product-db.vpc.nautible-dev.com
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: secret-nautible-app-product-db
                  key: DATABASE_USER
            - name: DB_PW
              valueFrom:
                secretKeyRef:
                  name: secret-nautible-app-product-db
                  key: DATABASE_PW
