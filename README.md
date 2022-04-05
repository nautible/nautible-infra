# nautible-infra

クラウド環境を構築するTerraformのリソースを管理する

- aws
  - AWSへKubernetesをデプロイするためのリソースを管理
- azure
  - AzureへKubernetesをデプロイするためのリソースを管理

クラウド別フォルダ内では以下のTerraformリソースを管理している

- platform
  - KubernetesおよびKubernetesを稼働させるために必要なリソースの構築
- app-ms
  - nautible-app-ms-xxxアプリケーションで利用するクラウドリソースの構築（データベース、キュー等）
