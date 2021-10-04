# KEDA

 Kubernetesでイベント駆動型のPodレベルオートスケールを可能にするフレームワーク

# 特徴

- HorizontalPodAutoscaler＋0←→1のスケーリングを可能とする
- Jobのスケーリングにも対応する
- 多様なトリガーに対応する(CPU/Memory/キュー/ストリーム等)

# KEDAのアーキテクチャ

[コンセプト](https://keda.sh/docs/2.0/concepts/)

KEDAの主要コンポーネント（Scaler,Contoroller,MetricsAdapter）とKubernetesの標準機構であるHorizontalPodAutoscalerの組み合わせで実現している。  

- Scaler
  - トリガーをとなるリソース（RabbitMQやSQS等）に接続してメトリクスを読み取る  
  - 接続するリソースごとにScalerは用意されている　[Scaler一覧](https://keda.sh/docs/2.0/scalers/)
- Contoroller
  - Podの0→1、0←1のスケール処理を行う
- MetricsAdapter
  - メトリクスをHorizontalPodAutoscalerに転送する
- HorizontalPodAutoscaler（Kubernetesの標準機能）
  - Podの1→n、1←nのスケール処理を行う

## install

```
$ kubectl apply -f application.yaml
```

もしくはArgoCD/ecosystems/overlays/aws/dev/application.yamlまたはArgoCD/ecosystems/overlays/azure/dev/application.yamlを使用してデプロイ

## デプロイ時の設定(values.yamlの設定)

公式のインストールドキュメントを参照

[artifacthub.io](https://artifacthub.io/packages/helm/kedacore/keda#configuration)

## uninstall

ArgoCDのコンソールからアプリケーションを削除するか、下記kubectlで削除する

```
$ kubectl delete -f application.yaml
```

※ArgoCD/ecosystems/overlays/*/dev/application.yamlからデプロイしている場合は、ArgoCD/ecosystems/base/kustomization.yamlからkedaのyamlを削除する

# CRDについて
## ScaledObject

イベントソース（RabbiMQ、SQS等）とKubernetesのリソース（Deployment,Statefulset,/scaleを定義する任意のカスタムリソース）をマッピングする  
HorizontalPodAutoscalerリソースにKEDAの機能を追加したようなカスタムリソース

[マニフェスト定義](https://keda.sh/docs/2.0/concepts/scaling-deployments/#scaledobject-spec)

## ScaledJob

イベントソース（RabbiMQ、SQS等）とKubernetesのJobリソースをマッピングする  
JobリソースにKEDAの機能を追加したようなカスタムリソース  

[マニフェスト定義](https://keda.sh/docs/2.0/concepts/scaling-jobs/#scaledjob-spec)

## TriggerAuthentication

イベントリソースへアクセスするための認証情報の定義（オプション）

[マニフェスト定義](https://keda.sh/docs/2.0/concepts/authentication/#re-use-credentials-and-delegate-auth-with-triggerauthentication)

# 利用方法

## AWS SQSをイベントリソースとする場合の例

### 事前準備

SQSの操作権限を持ったユーザーを作成しておき、Access key IDとSecret access keyを控えておく  

キューの内容確認をする必要があることと、デッドレターへの移し替えを行うため、以下の権限をユーザーには付与する

- SQS:Get*
- SQS:SendMessage
- SQS:ReceiveMessage
- SQS:DeleteMessage

### secretの作成

secretにAccess key IDとSecret access keyを作成する  
なお、機密情報なのでsecretに直接値は定義せずにシークレットを管理する機構（AWSの場合SystemManager等）に値を設定し、external-secretsでsecretを定義する

### 認証情報

ScaledObject/ScaledJobからSQSへアクセスするための認証設定  
secretのname,keyを指定する  

```
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: aws-demo-service-queue-credentials
  namespace: default
spec:
  secretTargetRef:
  - parameter: awsAccessKeyID
    name: secret-sqs
    key: accesskey
  - parameter: awsSecretAccessKey
    name: secret-sqs
    key: secretkey
```

また、Secretの参照以外にもクラウドプロバイダの機能を利用することも可能（未検証）  
[認証に関するドキュメント](https://keda.sh/docs/2.0/concepts/authentication/)

### ScaledObject

scaleTargetRefにDeploymentのmetadata.name、triggersにSQSを定義することでトリガーとアプリの紐付けを行う

```
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: aws-demo-service-queue-scaledobject
  namespace: default
spec:
  scaleTargetRef:                              # HorizontalPodAutoscalerと同等
    name: demo-service2-deployment
    kind: Deployment
    apiVersion: apps/v1
  pollingInterval: 5                           # ポーリング間隔
  cooldownPeriod: 30                           # Podを停止させるまでの時間
  maxReplicaCount: 10                          # 最大レプリカ数
  minReplicaCount: 0                           # 最小レプリカ数
  triggers:                                    # SQSへのトリガ
  - type: aws-sqs-queue
    authenticationRef:
      name: aws-demo-service-queue-credentials # TriggerAuthenticationのmetadata.apiVersion: apps/v1
    metadata:
      queueURL: https://sqs.ap-northeast-1.amazonaws.com/xxxxxxxxxxxx/demo-service-queue
      queueLength: "5"
      awsRegion: ap-northeast-1
```

### ScaledJob

コンテナをJobとして起動したい場合（処理後終了するコンテナを起動したい場合）、ScaledJobを利用する  
spec.jobTargetRef.templateにJobの定義を（Jobリソースのspec.template）記述する  

```
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: aws-demo-service-queue-scaledobject
  namespace: default
spec:
  jobTargetRef:                                # Jobと同等
    parallelism: 1
    completions: 1
    activeDeadlineSeconds: 600
    backoffLimit: 6
    template:
      spec:
        containers:
        - name: demo-service2
          image: xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/demo-service2:latest
  pollingInterval: 30                          # ポーリング間隔
  successfulJobsHistoryLimit: 5                # Jobの成功履歴数
  failedJobsHistoryLimit: 5                    # Jobの失敗履歴数
  maxReplicaCount：10                          # 最大レプリカ数
  triggers:                                    # SQSへのトリガ
  - type: aws-sqs-queue
    authenticationRef:
      name: aws-demo-service-queue-credentials
    metadata:
      queueURL: https://sqs.ap-northeast-1.amazonaws.com/xxxxxxxxxxxx/demo-service-queue
      queueLength: "5"
      awsRegion: ap-northeast-1
```