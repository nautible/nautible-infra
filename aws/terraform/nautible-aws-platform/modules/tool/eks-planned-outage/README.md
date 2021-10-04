# nautible EKS計画停止・起動

## 機能概要
EKSのAutoScalingGroupの最小・最大・希望のノード数を更新することで、EKSのEC2を計画停止・起動する。夜間や土日を停止することで費用の削減を行う事が目的。以下の方式で実現する。
* AWS Lambdaでノード数を更新する
* Lambdaの実行はAWS Cloudwatch Event(cron)
* k8sのcronjobでnautible appの再起動
全ノードの再起動という特殊な処理を行っているので、例えばdaprのpodよりアプリのpodが先に起動されてdaprのしsidecarがinjectionされない場合がある。そのための再起動

## terraformにて作成するリソース
* ノード数を更新するLambda
* Lambdaを実行するrole/policy
* Lambdaを実行するCloudwatch Event(cron)

## 使い方
* variables.tfの値を実行環境に合わせて編集する
* terraform applyでデプロイする
* nautible-app-restart.yamlのjobの実行時間、再起動対象を実行環境に合わせて編集する
* 「kubectl apply -f nautible-app-restart.yaml」で実行環境にデプロイする（terraformに組み込んでもメリットなさそうなので手動でapply実行

