# ArgoCD

Kubernetesでの利用を前提とした宣言型のGitOps継続的配信ツール。

本ドキュメントでは以下のサンプルもしくは導入手順を提供する。

- ArgoCDのインストール
- CLIの導入
- kubernetes-external-secretsによるシークレット管理（シークレットの格納場所：AWSSystemsManagerパラメータストア）
- プロジェクト作成（プロジェクトごとの権限管理）
- アプリケーションデプロイ用マニフェスト
- App of Apps （kustomize版）

公式ドキュメントは[こちら](https://argoproj.github.io/argo-cd/)  
公式リポジトリは[こちら](https://github.com/argoproj/argo-cd)


## インストール

stable版を導入

```
$ kubectl create namespace argocd
$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

[インストールドキュメント](https://argoproj.github.io/argo-cd/getting_started/#1-install-argo-cd)

## 管理画面へのログイン

### ポートフォワードでのログイン

```
$ kubectl port-forward svc/argocd-server -n argocd 8443:443
```

ブラウザで`https://localhost:8443`にアクセス

![ArgoCD](./images/pic-202107-001.jpg)

### 初期アカウント

Usrename : admin  
Password : 以下のsecretに記載（Windowsはbase64コマンドがないため、パイプ「|」以降は書かずにエンコード文字列を出力して他の方法でデコード ※WSLであればそのまま実行可）

```
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### （参考）エンドポイントの公開方法

ArgoCDへはポートフォワード、ServiceをLoadBalancerにする、Ingressを使用する、のいずれかでアクセス可能  
（外部NWからArgoCDの管理画面へ直接の接続を許容しない場合はポートフォワードにしておく、接続を許容する場合はService（LoadBalancer）、Ingressを使用するなどの選択肢がある）

## ArgoCDプロジェクトの作成

ArgoCDではアプリケーションのデプロイ権限を切り分ける手段としてプロジェクトという単位を提供している。  
プロジェクト単位で利用可能なソースリポジトリやデプロイ可能なクラスタ、namespeceなどを定義することで、アプリケーションが想定外のデプロイを行わないように制御する。

参考マニフェストは[こちら](https://argo-cd.readthedocs.io/en/stable/operator-manual/project.yaml)


### nautibleデモアプリケーション用のプロジェクトをデプロイ

```
$ kubectl apply -f ArgoCD/application-project.yaml
```

### ArgoCDからアクセスするGitリポジトリの定義をデプロイ

```
$ kubectl apply -f ArgoCD/argocd-cm.yaml
```

参考マニフェストは[こちら](https://argo-cd.readthedocs.io/en/stable/operator-manual/argocd-cm.yaml)

### Githubのリポジトリがプライベートリポジトリの場合

Githubがプライベートリポジトリの場合、下記のようにクラスタにシークレットでユーザIDとトークンを用意し、Githubアクセス時の認証に使用する。

#### ExternalSecrets

ExternalSecretsをデプロイ

事前にSystemManager（AWSの場合）、AzureKeyVault（Azureの場合）にシークレットを定義しておく

AWS（SystemManager）の例

ArgoCD/secrets/overlays/aws/github.yaml

```
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: secret-github
  namespace: argocd
spec:
  backendType: systemManager
  data:
    - key: /nautible-infra/github/user   # SystemManager key
      name: github-user                   # Deployment name
    - key: /nautible-infra/github/token  # SystemManager key
      name: github-token                  # Deployment name
```

Azureの例

ArgoCD/secrets/overlays/azure/github.yaml

```
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: secret-github
  namespace: argocd
spec:
  backendType: azureKeyVault
  keyVaultName: nautibledevkeyvault
  data:
    - key: nautible-infra-github-user   # SystemManager key
      name: github-user                   # Deployment name
    - key: nautible-infra-github-token  # SystemManager key
      name: github-token                  # Deployment name
```

#### kustomization.yaml

ArgoCD/secrets/overlays配下にあるkustomization.yamlのresourcesにgithub.yamlを追加することで、ArgoCDが自動デプロイする。

#### ConfigMap

リポジトリへアクセスするためのユーザ名、シークレットを追記する。

```
    - url: https://github.com/nautible/nautible-app-customer-manifest
      name: nautible-app-customer-manifest
+     passwordSecret:
+       name: secret-github
+       key: github-token
+     usernameSecret:
+       name: secret-github
+       key: github-user
```

※ 上記設定をすべてのプライベートリポジトリに追加する

## アプリケーション導入設定

ArgoCDによるGitOpsを実現するにはArgoCDのカスタムリソースであるApplicationを作成する。  
Applicationリソースでは基本的に下記の３つを設定する。

- 導入元（リポジトリパス）
- 導入先（Kubernetesおよびnamespace）
- 同期ポリシー（自動か手動かなど）

[マニフェストのサンプルこちら](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)（Applicationリソースはapplication.yamlに記載）

## 導入アプリケーション

nautibleで導入するアプリケーション（エコシステム、シークレット、サンプルアプリケーション）は下記の通り。

導入手順は[README](../README.md)を参照
### エコシステム

| 名称 | AWS | Azure | GCP | 備考 |
| ---- | ---- | ---- | ---- | ---- |
| [MetricsServer](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/metrics-server.html) | 〇 | × | - | - |
| [Istio](https://istio.io/) | 〇 | 〇 | - | - |
| [autoscaler](https://github.com/kubernetes/autoscaler) | 〇 | × | - | - |
| [Dapr](https://dapr.io/) | 〇 | 〇 | - | - |
| [KEDA](https://keda.sh/) | 〇 | 〇 | - | - |
| [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) | 〇 | 〇 | - | - |
| [loki](https://grafana.com/oss/loki/) | 〇 | 〇 | - | - |
| [prometheus-operator](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | 〇 | 〇 | - | - |
| [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) | 〇 | 〇 | - | - |
| [prometheus monitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md) | 〇 | 〇 | - | - |
| [prometheus rules](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/alerting.md) | 〇 | 〇 | - | - |

### シークレット  

AWSの場合  

| 名称 | 備考 |
| ---- | ---- |
| github | Githubプライベートリポジトリアクセスキー（実装サンプル） |
| product-db | 商品サービスデータベース接続キー（実装サンプル） |
| sqs | SQS接続キー（実装サンプル） |

Azureの場合  

| 名称 | 備考 |
| ---- | ---- |
| github | Githubプライベートリポジトリアクセスキー（実装サンプル） |
| common | Azure Servicebus(dapr pub/sub)接続キー（実装サンプル） |
| cosmosdb | Cosmosdb接続キー（実装サンプル） |
| order | rediscache(dapr statestor)接続キー（実装サンプル） |  

### サンプルアプリケーション

| 名称 | 備考 |
| ---- | ---- |
| [nautible-app-customer](https://github.com/nautible/nautible-app-customer) | 顧客サービス（実装サンプル） |
| [nautible-app-product](https://github.com/nautible/nautible-app-product) | 商品サービス（実装サンプル） |
| [nautible-app-stock](https://github.com/nautible/nautible-app-stock) | 在庫サービス（実装サンプル） |
| [nautible-app-order](https://github.com/nautible/nautible-app-order) | 注文サービス（実装サンプル） |
| [nautible-app-payment](https://github.com/nautible/nautible-app-payment) | 決済サービス（実装サンプル） |

[注意]
- helmのインストールパラメータを変更する必要がある場合は、ファイルを編集するか、kustomizeを活用して対応する必要がある  
  - ArgoCD/ecosystems/overlays/aws/base/autoscaler/application.yamlの「autoDiscovery.clusterName（デフォルト:nautible-dev-cluster）」「awsRegion（デフォルト:ap-northeast-1）」


# アップグレード

＜version＞ 部分にアップグレードしたいバージョンを入れて実行

```
$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/<version>/manifests/install.yaml

例）
$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.1.4/manifests/install.yaml
```

# Tips

- Helmでインストールする場合、HelmのapiVersionがv1（Helm2を指す）だとCRDが自動で入らない。その場合はCRDをインストールするApplicationが必要になる。
