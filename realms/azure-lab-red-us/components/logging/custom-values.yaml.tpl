apiVersion: v1
kind: PersistentVolume
metadata:
  name: kibana-lab-red-us
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.109.196.5
    path: 10.109.196.5:/kibana-lab-red-us
---   
    
# Default values for efk.

# https://github.com/helm/charts/blob/master/stable/kibana/values.yaml
kibana:
  image:
    repository: "docker.elastic.co/kibana/kibana-oss"
    tag: "6.4.2"
  env:
    # All Kibana configuration options are adjustable via env vars.
    # To adjust a config option to an env var uppercase + replace `.` with `_`
    # Ref: https://www.elastic.co/guide/en/kibana/current/settings.html
    #
    ELASTICSEARCH_URL: http://{{ .Release.Name }}-elasticsearch-client
    SERVER_PORT: 5601
    LOGGING_VERBOSE: "true"
    SERVER_DEFAULTROUTE: "/app/kibana"
  storage:
      volumeClaimTemplate:
        spec:
          volumeMounts:
            - name: kibana-lab-us-red
              mountPath: 10.109.196.5:/kibana-lab-red-us   

# https://github.com/komljen/helm-charts/blob/master/elasticsearch/values.yaml
elasticsearch:
  enabled: true
    
# https://github.com/helm/charts/blob/master/stable/fluent-bit/values.yaml
fluent-bit:
  enabled: true
  image:
    fluent_bit:
      repository: fluent/fluent-bit
      tag: 1.1.1
  backend:
    type: es
    es:
      host: {{ .Release.Name }}-elasticsearch-client
      port: 9200
      index: kubernetes_cluster
      logstash_prefix: kubernetes_cluster

# https://github.com/helm/charts/blob/master/stable/elasticsearch-curator/values.yaml
elasticsearch-curator:
  config:
    elasticsearch:
      hosts:
        - {{ .Release.Name }}-elasticsearch-client

# https://github.com/helm/charts/blob/master/stable/filebeat/values.yaml
filebeat:
  enabled: true
  config:
    setup.template.name: "kubernetes_cluster"
    setup.template.pattern: "kubernetes_cluster-*"
    processors:
    - decode_json_fields:
        fields: ["message"]
        process_array: true
        max_depth: 8
        target: ""
    filebeat.prospectors:
      - type: docker
        containers.ids:
        - "*"
        processors:
          - add_kubernetes_metadata:
              in_cluster: true
          - drop_event:
              when:
                equals:
                  kubernetes.container.name: "filebeat"
    output.file:
      enabled: false
    output.elasticsearch:
      hosts: ["http://{{ .Release.Name }}-elasticsearch-client:9200"]
  privileged: true

# https://github.com/helm/charts/blob/master/stable/metricbeat/values.yaml
metricbeat:
  enabled: false
  daemonset:
    enabled: false

  deployment:
    config:
      setup.template.name: "kubernetes_events"
      setup.template.pattern: "kubernetes_events-*"
      output.elasticsearch:
        hosts: ["http://{{ .Release.Name }}-elasticsearch-client:9200"]
      output.file:
        enabled: false
    modules:
      kubernetes:
        enabled: true
        config:
          - module: kubernetes
            metricsets:
              - event