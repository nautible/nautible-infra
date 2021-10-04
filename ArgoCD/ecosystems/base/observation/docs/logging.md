# ロギング

## ロギングアーキテクチャ

![logging](https://user-images.githubusercontent.com/29446925/100202850-35651d00-2f45-11eb-88cd-e112750ba809.png)

## アプリケーション側のログ出力

アプリケーション側ではJSONで構造化したログを出力する。  
構造化するフォーマットはアプリケーションごとに自由に項目を設定するのではなく、プロジェクト全体でいくつか定義を定めて管理するほうが運用しやすいと考えられる。  

```
ログの例

{
  "level": "INFO",
  "dt": "2020/11/01T12:00:00+0900,
  "id": "1234-5678",
  "url": "https://example.com/service/",
  "method": "serviceApplication",
  "message": "trace start" 
}
```

## Promtailの設定

promtail/application.yaml

HelmのvaluesにpipelineStagesを設定することでログ取得時のラベリングやメトリクスの設定を行う。

```
...
      values: |
        loki:
          serviceName: loki
        syslogService:
          enabled: false
        serviceMonitor:
          enabled: true
        pipelineStages:
        - docker:
        - match:
            selector: '{app=~"demo-.*"}' # マッチングするPodの選択
            stages:
            - json:                      # JSONの定義（右辺にはJSONで定義している項目名、左辺は本Stageで扱う変数）
                expressions:
                  level: level
                  dt: dt
                  id: id
                  url: url
                  method: method
                  message: message
            - labels:                    # ラベルの付与（expressionsの左辺と同じ名前にしておけば右辺は省略可）
                level:
                dt:
                id:
                url:
                method:
                message:
            - metrics:                   # メトリクス設定（levelにERRORが入ってたらカウントアップするメトリクス例）
                log_error_total:
                  type: Counter
                  description: error number
                  prefix: promtail_custom_
                  source: level
                  config:
                    value: ERROR
                    action: inc
...
```

なお、ログを非構造のテキストで出力している場合、stagesの「json」を「regex」にすることで正規表現で項目を抽出できる。  
ただし、正規表現は一見で理解することが難しくなることが多く不具合を含みやすいため、構造化ログを推奨する。

## Grafanaでログの確認

### ログの各項目がラベルとして認識されていることの確認

![grafana4](https://user-images.githubusercontent.com/29446925/100298821-73118680-2fd5-11eb-9be3-14d0c79efaf7.png)

### ラベルで絞込み

ERRORで絞り込む例

![grafana5](https://user-images.githubusercontent.com/29446925/100299021-ffbc4480-2fd5-11eb-9ee1-089c2d2612ea.png)

## エラーログの検知方法

エラーログの発生カウントをPrometheusでメトリクスとして収集し、Alertmanagerで発報することで検知する。  

### エラーログのメトリクス収集

levelの値がERRORの時にメトリクスとして収集する例

```
...
            - metrics:                   # メトリクス設定（levelにERRORが入ってたらカウントアップするメトリクス例）
                log_error_total:
                  type: Counter
                  description: error number
                  prefix: promtail_custom_
                  source: level
                  config:
                    value: ERROR
                    action: inc
...
```

監視ルールでpromtail_custom_log_error_totalの値が1以上の時にwarningを発報する例

[rulesファイル](https://github.com/nautible/nautible-infra/blob/main/ArgoCD/ecosystems/base/observation/rules/base/demo-rule.yaml)

```
  - name: rules-demo-alert2
    rules:
    - alert: ApplicationError
      expr: >-
          count (promtail_custom_log_error_total) > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        message: >-
          {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are application error.
```

### Prometheusで確認


![alert1](https://user-images.githubusercontent.com/29446925/100311442-1fae3100-2ff3-11eb-81e4-f0c180837296.png)

### Alertmanagerで確認

Alertmanager上へ転送されている

![alert2](https://user-images.githubusercontent.com/29446925/100311453-29379900-2ff3-11eb-9d5c-2811b9513387.png)