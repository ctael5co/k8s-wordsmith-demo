local configmap = import 'configmap.template.jsonnet';
local serviceaccount = import 'serviceaccount.template.jsonnet';
local deployment = import 'deployment.template.jsonnet';
local clusterrole = import 'clusterrole.template.jsonnet';
local clusterrolebinding = import 'clusterrolebinding.template.jsonnet';
local service = import 'service.template.jsonnet';

local cm = configmap + {
  name: "prometheus-config",
  data: {
    "prometheus.yml": |||
      scrape_configs:
      - job_name: prometheus
        static_configs:
        - targets:
          - localhost:9090
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scrape
        - action: replace
          regex: (.+)
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_path
          target_label: __metrics_path__
        - action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          source_labels:
          - __address__
          - __meta_kubernetes_pod_annotation_prometheus_io_port
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_name
          target_label: kubernetes_pod_name
    |||
  }
};

local dep = deployment + {
  name: "prometheus",
  dockerImage: "prom/prometheus:v2.2.1",
  spec+: {
    template+: {
      spec+: {
        containers: [
          {
            name: "prometheus",
            image: $.dockerImage,
            args: [
              "--config.file=/etc/config/prometheus.yml",
              "--web.console.libraries=/etc/prometheus/console_libraries",
              "--web.console.templates=/etc/prometheus/consoles",
              "--web.enable-lifecycle",
            ],
            ports: [ {"containerPort": 9090 }],
            readinessProbe: {
              httpGet: { path: "/-/ready", port: 9090 },
              initialDelaySeconds: 30,
              timeoutSeconds: 30
            },
            livenessProbe: {
              httpGet: { path: "/-/healthy", port: 9090 },
              initialDelaySeconds: 30,
              timeoutSeconds: 30,
            },
            resources: {
              limits: {cpu: "200m", memory: "128Mi"},
              requests: {cpu: "200m", memory: "128Mi"}
            },
            volumeMounts: [{name: "config-volume", mountPath: "/etc/config"}],
          },
        ],
        serviceAccountName: "prometheus",
        volumes: [{ name: "config-volume",configMap: {name: "prometheus-config"}}],
      }
    }
  }
};
local sa = serviceaccount + {
  name: "prometheus",
  labels: {
    "kubernetes.io/cluster-service": "true"
  }
};

local cr = clusterrole + {
  name: "prometheus",
  labels: {
    "kubernetes.io/cluster-service": "true"
  },
  rules: [
    {
      apiGroups: [""],
      resources: ["nodes","nodes/metrics","services","endpoints","pods"],
      verbs: ["get","list","watch"],
    },
    {
      apiGroups: [""],
      resources: ["configmaps"],
      verbs: ["get"],
    },
    {
      nonResourceURLs: ["/metrics"],
      verbs: ["get"],
    },
  ],
};

local crb = clusterrolebinding + {
  name: "prometheus",
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "prometheus",
  },
  subjects: [],
};

local svc = service + {
  name: "prometheus",
};


local newShard(conf) = {
  configMap: cm,
  deployment: dep,
  serviceaccount: sa,
  clusterrole: cr,
  clusterrolebinding: crb,
  service: svc
};

{
  newShard:: newShard,
}
