# nautible-infra

## 概要

各クラウド環境へKubernetesを導入するためのリポジトリです。  
Terraformを使いVPC等Kubernetesを稼働させる環境の構築やKubernetesの導入、アプリケーションで利用するクラウドリソースの作成を行います。

また、アプリケーションやエコシステムなどを導入するためのCI/CD環境構築手順も管理しています。

## 構成

### Kubernetes環境構築

- aws
  - AWSへKubernetesをデプロイするためのリソースを管理
- azure
  - AzureへKubernetesをデプロイするためのリソースを管理

クラウド別ディレクトリ内では以下の構成でTerraformリソースを管理しています。

- platform
  - KubernetesおよびKubernetesを稼働させるために必要なリソースの構築
- app-ms
  - nautible-app-ms-xxxアプリケーションで利用するクラウドリソースの構築（データベース、キュー等）

### CI/CD環境構築

- ci_cd
  - ArgoCDを用いたCI/CD環境構築手順及びnautible環境構築用リソースファイルを管理

## 構築手順

- Terraformによる環境構築
  - [EKS環境構築](https://github.com/nautible/nautible-infra/tree/main/aws/platform/README.md)
  - [AKS環境構築](https://github.com/nautible/nautible-infra/tree/main/azure/platform/README.md)
  - [EKS上にマイクロサービスアプリケーション用リソースを構築](https://github.com/nautible/nautible-infra/tree/main/aws/app-ms/README.md)
  - [AKS上にマイクロサービスアプリケーション用リソースを構築](https://github.com/nautible/nautible-infra/tree/main/azure/app-ms/README.md)
- [CI/CD環境構築](https://github.com/nautible/nautible-infra/tree/main/ci_cd/README.md)
