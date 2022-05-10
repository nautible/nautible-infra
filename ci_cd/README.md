# CI/CD

GithubActionsとArgoCDを用いたGitOps環境を構築します。

## 全体像

![アーキテクチャイメージ](./docs/images/architecture.png)

## CI環境の準備

### GtihubActions

GithubActionsでは以下の２点の機能を実現します。

- コードをビルドしコンテナイメージをコンテナレジストリにPushする。
- マニフェスト用リポジトリにあるDeploymentリソースにあるイメージタグを最新のタグ名に変更してプルリクエストを作成する。

[GithubActionsのセットアップ手順はこちら](./docs/githubactions.md)

## CD環境の準備

### ArgoCD

ArgoCDでは以下の機能を実現します。

- Github上で各アプリケーション（もしくはエコシステム）のマニフェストが更新された際にKubernetesの状態をGitと同じ状態に更新する。

[ArgoCDのセットアップ手順はこちら](./docs/argocd.md)

## エコシステム及びアプリケーションの導入手順

エコシステム及びアプリケーションの導入はnautible-pluginプロジェクトで実施します。

詳細は[nautible-plugin](https://github.com/nautible/nautible-plugin)のドキュメントを参照してください。

## （参考）AWSマネージドサービスを活用したCI/CD構成

AWSマネージドサービスを活用したCI/CDは[こちら](https://github.com/nautible/nautible-infra-codebuild)を参照してください。
