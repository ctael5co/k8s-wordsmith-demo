local utils = import "utils.libsonnet";
local prometheus = (import "prom2.template.jsonnet");
local configmap = import "configmap.template.jsonnet";

// customer specific variables
local conf = import "cust2.json";

local prom = prometheus.newShard(conf) + {
  // extending the prometheus deployment object
  deployment+: {
    name: "prometheus-cust2",
    shard: "cust2"
  },
  serviceaccount+: {
    name: conf.prometheus.serviceAccount,
  },
  clusterrolebinding+: {
    subjects+:[ { kind: "ServiceAccount", name: conf.prometheus.serviceAccount, namespace: conf.prometheus.namespace }]
  },
  service+: {
    type: "LoadBalancer",
    ports: [
      {name: "http", port: 9090, protocol: "TCP", targetPort: 9090}
    ],
    selector: {name: "prometheus-cust2"}
  },
};


utils.kubeListArray([prom])
