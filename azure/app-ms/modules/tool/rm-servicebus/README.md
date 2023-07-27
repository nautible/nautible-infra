# ServiceBus日次削除

## 機能概要
AzureのautomationでServiceBusを削除する。ネットワーク設定、firewall設定の要件でPremiumを利用するが、Premiumは700ドル/月とコストが高く、ServiceBusは停止概念が無いため日次で削除する。

## terraformにて作成するリソース
* automation account
* 起動コマンド実行用のrunbook
* 停止コマンド実行用のrunbook

## 使い方
* variables.tfの値を実行環境に合わせて編集する
* terraform applyでデプロイする

