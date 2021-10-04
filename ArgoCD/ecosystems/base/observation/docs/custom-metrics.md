# 独自の監視対象を追加する

## ServiceMonitorアーキテクチャ

PrometheusがServiceMonitorを検出し、ServiceMonitorが各サービスを検出するアーキテクチャとなる。  
検出はラベルを使って制御する。  

![archtecture](https://user-images.githubusercontent.com/29446925/99483907-99666f00-29a2-11eb-9959-276c7ad6780f.png)

[出典：prometheus-operator](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md)

## アプリケーションの対応

アプリケーション独自のメトリクスを公開する場合、エンドポイント/metricsを公開する。

golangの例  
HTTPリクエストが来るたびにカウンタをインクリメントし、http_request_totalの名前でリクエスト数を公開する  

```
package main

import (
    "fmt"
    "io/ioutil"
    "net/http"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpReqs = prometheus.NewCounterVec(
            prometheus.CounterOpts{
                    Name: "http_request_total",
                    Help: "How many HTTP requests processed, partitioned by status code and HTTP method.",
            },
            []string{"code", "method"},
    )
)

func init() {
    prometheus.MustRegister(httpReqs)
}

func metrics(w http.ResponseWriter, r *http.Request) {
    promhttp.Handler().ServeHTTP(w, r)
}

func handler(w http.ResponseWriter, r *http.Request) {
    m := httpReqs.WithLabelValues("200", "GET")
    m.Inc()
...
```

## ServiceMonitorの作成

defaultネームスペースでservice: demoのラベルを持つサービスをモニターする例  

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor

metadata:
  name: observation-servicemonitor-demo-service
  namespace: default
  labels:
    serviceapp: demo-service
    release: prometheus-operator    # 固定値（PrometheusはこのラベルでServiceMonitorを検出する）
spec:
  selector:
    matchLabels:
      service: demo  # モニター対象のサービスを特定する(endpointsリソースのラベルを指定)
  endpoints:
  - port: http            # ポート（サービスのspec.ports.name）
    interval: 30s
  namespaceSelector:
    matchNames:
    - default             # モニター対象のネームスペース
```

※labels.releaseはprometheus でセレクタとして設定されてる値なので、固定値となる。 

なお、セレクタの確認は以下の通り

```
$ kubectl get prometheus -n observation -o yaml

...
    serviceMonitorSelector:
      matchLabels:
        release: prometheus-operator
...
```

アプリケーション側は下記のようにapp: demoのラベルを持つServiceでデプロイする

```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    service: demo
    app: demo-service1
  name: demo-service1
spec:
  ports:
  - name: http
    port: 18080
    protocol: TCP
    targetPort: 18080
  selector:
    app: demo-service1
  type: ClusterIP
status:
  loadBalancer: {}

```

上記ServiceMonitorをデプロイすると、下記のようにPrometheusのTargetに表示される

![prometheus1](https://user-images.githubusercontent.com/29446925/99483109-ea756380-29a0-11eb-8aad-66ee26af1216.png)

Grafanaで確認する

![grafana3](https://user-images.githubusercontent.com/29446925/99477506-fa3b7a80-2995-11eb-81a7-86e02d4f6f97.png)