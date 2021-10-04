# nautible-admission-webhook

## nautible-awの機能
* 環境変数をpod起動時に適用する
  * 適用対象のpodのruleを定義
    *  適用対象に含めるpod名の指定(正規表現)
    *  適用対象外とするnamespaceの指定(正規表現)

## nautible-admission-webhookの適用方法
* 以下のコマンドを実行して、nautible-acのdocker imageを作成する
    ```
    docker build -t nautible/nautible-ac:1.0.0 .
    ```
* deploy/deployment.yamlにproxy設定を行う

* 以下のコマンドを生成してnautibleのnamespaceを作成する
    ```
    kubectl create namespace nautible
    ```

* minikubeのsecretにプロキシ設定を追加する
    ```
    kubectl create secret generic proxy -n nautible --from-literal=http_proxy=<HTTPプロキシ設定> --from-literal=https_proxy=<HTTPSプロキシ設定>
    ```

* deployフォルダにて以下のコマンドを実行してnautible-awをデプロイする
    ```
    kubectl apply -f .
    ```

## nautible-awの開発
* 参考情報
  * [k8s公式(Doc)](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
  * [k8s公式(golangAPI)](https://godoc.org/k8s.io/api/admission/v1)

* 開発の前提条件
  * dockerのインストール
  * [cfssl](https://github.com/cloudflare/cfssl)のインストール

* 証明書生成
  * certs/server-csr.json のdomainやnamespaceを編集
  * 以下のコマンドで証明書を作成
    ```
    make cert/generate
    ```
* 証明書設定
  * 生成されたcaをdeploy/webhook-configuration.yamlのcaBundleに設定する
  * 生成されたcertをdeploy/secret.yamlのcert.pemに設定する
  * 生成されたkeyをdeploy/secret.yamlのkey.pemに設定する

