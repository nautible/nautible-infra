# セットアップ

以下のプロダクトをKubernetesにデプロイする

- モニタリング
  - Prometheus-Operator(kube-prometheus-stack)
    - Prometheus
    - Alertmanager
    - Grafana
    - Node-Exporter
    - kube-state-metrics
- ロギング
  - GrafanaLoki
  - Promtail
- トレーシング
  - TODO

## 前提

ローカルでkubectlが実行できること  
kubernetesにArgoCDがデプロイされていること

## 事前準備

EKSの場合、デフォルトでメトリクスサーバーのPodがデプロイされていないため、デプロイしておく。

```
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
$ kubectl get deployment metrics-server -n kube-system

NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           6m
```

## namespaceの作成

### 実行

```
$ kubectl apply -f namespace.yaml
```

### 確認

```
$ kubectl get ns

NAME                          STATUS   AGE
observation                   Active   12s
```

## CRDのデプロイ

### 実行
```
$ kubectl apply -f prometheus-operator/application-crd.yaml
```

### 確認

```
$ kubectl get crd

NAME                                         CREATED AT
alertmanagerconfigs.monitoring.coreos.com    2020-11-13T05:52:49Z
alertmanagers.monitoring.coreos.com          2020-11-13T05:52:57Z
podmonitors.monitoring.coreos.com            2020-11-13T05:53:04Z
probes.monitoring.coreos.com                 2020-11-13T05:53:11Z
prometheuses.monitoring.coreos.com           2020-11-13T05:53:18Z
prometheusrules.monitoring.coreos.com        2020-11-13T05:53:25Z
servicemonitors.monitoring.coreos.com        2020-11-13T05:53:32Z
thanosrulers.monitoring.coreos.com           2020-11-13T05:53:40Z
```

CRDは上記以外にもあるため、kubectl get crdの結果に上記8個が含まれているかを確認する

## prometheus-operatorのデプロイ

### 実行
```
$ kubectl apply -f prometheus-operator/application-main.yaml
```

### Prometheus確認

```
$ kubectl port-forward svc/prometheus-operated -n observation 9090:9090
```

ブラウザでアクセス

http://localhost:9090

デフォルトではアラート確認用にWatchdogが常にエラーとして検出される  
※環境によりそのほかのアラートが出る場合もある（メモリの使い過ぎ、Podが多すぎるなど）  

![prometheus](https://user-images.githubusercontent.com/29446925/99369201-7afb6780-28ff-11eb-8dd4-7fcea31c11ff.png)

### Alertmanager確認

```
$ kubectl port-forward svc/alertmanager-operated -n observation 9093:9093
```

ブラウザでアクセス

http://localhost:9093

Prometheusで確認したWatchdogのアラートがこちらも表示される  

![alertmanager1](https://user-images.githubusercontent.com/29446925/99369446-c877d480-28ff-11eb-9903-b7e6aed63774.png)

![alertmanager2](https://user-images.githubusercontent.com/29446925/99369559-ed6c4780-28ff-11eb-8085-3ce8e6a3924e.png)

### Grafana確認

```
$ kubectl port-forward svc/prometheus-operator-grafana -n observation 80:80
```

ブラウザでアクセス

http://localhost

デフォルトのログインID/PWはadmin/prom-operator

![grafana1](https://user-images.githubusercontent.com/29446925/99370328-e5f96e00-2900-11eb-9bb0-b7b632f5e3e3.png)

デフォルトでPrometheusが設定されている

![grafana2](https://user-images.githubusercontent.com/29446925/99370477-12ad8580-2901-11eb-8b68-ae5e6baa4b6b.png)

## GrafanaLokiのデプロイ

### 実行

```
$ kubectl apply -f loki/application.yaml
```

### 確認

GrafanaLokiのserviceを表示してサービス名とPORTを確認

```
$ kubectl get svc -n observation

NAME                                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
loki                                           ClusterIP   10.100.84.148    <none>        3100/TCP                     8m26s
```

上記で確認したサービス名:PORTでPrometheusのデータソースにLokiを追加する  

![loki1](https://user-images.githubusercontent.com/29446925/99370833-82237500-2901-11eb-889e-f5b0a2773c18.png)

![loki2](https://user-images.githubusercontent.com/29446925/99498899-76948480-29bb-11eb-86f5-36b74aba1d9d.png)

## promtailのデプロイ

### 実行

```
$ kubectl apply -f promtail/application.yaml
```

### 確認

```
$ kubectl get ds -n observation

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
promtail                                       3         3         3       3            3           <none>          32s
```
