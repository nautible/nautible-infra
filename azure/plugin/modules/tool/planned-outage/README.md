# nautible 計画停止・起動

## 機能概要
AzureのautomationにてDBなど計画停止・起動する。夜間や土日を停止することで費用の削減を行う事が目的。

## terraformにて作成するリソース
* automation account
* 起動コマンド実行用のrunbook
* 停止コマンド実行用のrunbook

## 使い方
* variables.tfの値を実行環境に合わせて編集する
* terraform applyでデプロイする
* Azureのコンソールから「実行アカウント＞Azure実行アカウント作成＞作成ボタン押下」

