# EKS AutoMode用マニフェスト

## ノード設定

EKS AutoModeではNodeClass、NodePoolの２つのマニフェストで生成するノード（EC2）をコントロールします。  
組込のノード設定としては以下が定義されています。

- NodeClass
  - default
- NodePool
  - system
  - general-purpose

※ nautible-infraのデフォルトパラメータではgeneral-purposeノードプールは作成しません

systemノードプールはアドオン用、general-purposeノードプールはアドオン以外の通常のPod用として定義されています。上記組込以外のNodeClass、NodePoolを利用する場合は独自にマニフェストをデプロイする必要があります。

例として、開発環境用に低コストのノード（Spotインスタンス）を割り当てるNodePoolを導入します。

### 導入手順

#### NodeClassの導入

マニフェスト

```
manifests/eks-automode/nodeclass.yaml
```

必須で変更が必要な項目

ノードに付与するロールの設定。EKSコンソールを確認し、systemノードに設定されているロールと同じものを設定する。

```yaml
spec:
  role: <ロール名>
```

ノードに付与するセキュリティグループ。<クラスタ名>-eks-node-common-sgを設定する。

```yaml
spec:
  securityGroupSelectorTerms:
  - tags:
      Name: "nautible-dev-cluster-v1_32-eks-node-common-sg"
```

ノードを配置するサブネット。<プロジェクト名>-<環境名>-private-subnetを設定する。  
※ <プロジェクト名>、<環境名>はTerraformのvariablesで定義しているもの

```yaml
spec:
  subnetSelectorTerms:
  - tags:
      Name: "nautible-dev-private-subnet"

```

NodeClassのデプロイ

```bash
kubectl apply -f manifests/eks-automode/nodeclass.yaml
```

#### NodePoolの導入

マニフェスト

```
manifests/eks-automode/nodepool.yaml
```

NodePoolのデプロイ

```bash
kubectl apply -f manifests/eks-automode/nodepool.yaml
```

## ストレージ設定

EKS AutoModeで作成されたノードからEBSを利用するためのStorageClassをデプロイします。

### 導入手順

```bash
kubectl apply -f manifests/eks-automode/storageclass.yaml
```