# nautible-infra

## [CI/CD](https://github.com/nautible/nautible-infra/tree/main/ArgoCD)
ArgoCDのリソースを管理。GithubActionsとArgoCDを活用しGitOpsのCI/CDを行う。

## [aws/terraform](https://github.com/nautible/nautible-infra/tree/main/aws/terraform)
Terraformのリソースを管理。Terraformを活用しAWS環境のIaCを行う。

## [nautible-aw](https://github.com/nautible/nautible-infra/tree/main/k8s/nautible-aw)
nautibleのadmission webhook。社内proxy対応機能などを提供する。

## [external-secrets](https://github.com/nautible/nautible-infra/tree/main/ArgoCD/ecosystems/base/external-secrets)
機密情報管理。機密情報の実体をAWSSystemManagerで管理し、Kubernetesのリソースから機密情報へ安全にアクセスできる機能を提供する。
