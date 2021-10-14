# 環境構築

nautibleではクラウド、CI/CD環境を構築することができます。

## [クラウド環境の構築](https://github.com/nautible/nautible-infra/tree/main/aws/terraform)
クラウド環境のIaCをTerraformを利用して行っています。環境構築手順などの詳細についてはリンク先を参照してください。

## [CI/CD](https://github.com/nautible/nautible-infra/tree/main/ArgoCD)
GithubActionsとArgoCDを活用しGitOpsのCI/CDを行っています。環境構築手順などの詳細についてはリンク先を参照してください。

## その他

### [nautible-aw](https://github.com/nautible/nautible-infra/tree/main/k8s/nautible-aw)
nautibleのadmission webhook。社内proxy対応機能などを提供する。機能などの詳細についてはリンク先を参照してください。

### [external-secrets](https://github.com/nautible/nautible-infra/tree/main/ArgoCD/ecosystems/base/external-secrets)
機密情報管理。機密情報の実体をAWSSystemManagerで管理し、Kubernetesのリソースから機密情報へ安全にアクセスできる機能を提供する。
