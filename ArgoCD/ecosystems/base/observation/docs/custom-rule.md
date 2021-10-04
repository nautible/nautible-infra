# 監視ルールを追加する

## デプロイされているルールの一覧

```
$ kubectl get prometheusrules -n observation

NAME                                                              AGE
prometheus-operator-kube-p-alertmanager.rules                     3h30m
prometheus-operator-kube-p-general.rules                          3h30m
prometheus-operator-kube-p-k8s.rules                              3h30m
prometheus-operator-kube-p-kube-prometheus-general.rules          3h30m
prometheus-operator-kube-p-kube-prometheus-node-recording.rules   3h30m
prometheus-operator-kube-p-kube-state-metrics                     3h30m
prometheus-operator-kube-p-kubelet.rules                          3h30m
prometheus-operator-kube-p-kubernetes-apps                        3h30m
prometheus-operator-kube-p-kubernetes-resources                   3h30m
prometheus-operator-kube-p-kubernetes-storage                     3h30m
prometheus-operator-kube-p-kubernetes-system                      3h30m
prometheus-operator-kube-p-kubernetes-system-apiserver            3h30m
prometheus-operator-kube-p-kubernetes-system-kubelet              3h30m
prometheus-operator-kube-p-node-exporter                          3h30m
prometheus-operator-kube-p-node-exporter.rules                    3h30m
prometheus-operator-kube-p-node-network                           3h30m
prometheus-operator-kube-p-node.rules                             3h30m
prometheus-operator-kube-p-prometheus                             3h30m
prometheus-operator-kube-p-prometheus-operator                    3h30m
```

Prometheusの画面からでも確認できる（Status->Rules）

![prometheus2](https://user-images.githubusercontent.com/29446925/99491504-33341900-29af-11eb-865f-b8eb4948aec9.png)

## ルールの追加

カスタムリソースの作成  

```
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: demo-alert.rules
  namespace: observation
  labels:
    app: kube-prometheus-stack       # 固定値(kube-prometheus-stackで構築した場合この名前)
    release: prometheus-operator     # 固定値(kube-prometheus-stackで構築した場合この名前)
spec:
  groups:
  - name: rules-demo-alert
    rules:
    - alert: ApplicationDown
      expr: >-
          100 * (count(up == 0) BY (job, namespace, service) / count(up) BY (job, namespace, service)) > 10
      for: 10m
      labels:
        severity: warning
      annotations:
        message: >-
          {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down.
```

※lables.appとlabels.releaseはprometheus でセレクタとして設定されてる値なので、固定値となる。 

なお、セレクタの確認は以下の通り

```
$ kubectl get prometheus -n observation -o yaml

...
ruleSelector:
      matchLabels:
        app: kube-prometheus-stack
        release: prometheus-operator
...
```

カスタムリソースをデプロイしてしばらくするとPrometheusのRulesに検出される

![prometheus3](https://user-images.githubusercontent.com/29446925/99493718-0e41a500-29b3-11eb-8594-774072998193.png)

# デフォルトの監視ルールを無効化する

デフォルトの監視ルールはHelmデプロイの設定で有効化されているため、values.yamlを更新して反映する

## 全てのデフォルトルールを無効化する

prometheus-operator/application-main.yaml

valuesにdefaultRules.create: falseを追加する

```
...
  source:
    chart: 'kube-prometheus-stack'
    repoURL: 'https://prometheus-community.github.io/helm-charts'
    targetRevision: 12.0.1
    helm:
      version: v3
      releaseName: prometheus-operator
      values: |
        defaultRules:
          create: false
...
```

## 特定のデフォルトルールを無効化する（例はgeneralを無効化）

prometheus-operator/application-main.yaml

valuesにdefaultRules.rules.<ルール名>: falseを追加する

[ルール名の一覧はvalues.yamlのdefaultRulesを確認](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml)

```
...
  source:
    chart: 'kube-prometheus-stack'
    repoURL: 'https://prometheus-community.github.io/helm-charts'
    targetRevision: 12.0.1
    helm:
      version: v3
      releaseName: prometheus-operator
      values: |
        defaultRules:
          rules:
            general: false
...
```

## 反映

```
$ kubectl apply -f prometheus-operator/application-main.yaml
```

なお、デフォルトルールの設定値は変数化されていないため変更できない。  
変更したい場合はデフォルトルールを削除して、別にルールを作成する。  