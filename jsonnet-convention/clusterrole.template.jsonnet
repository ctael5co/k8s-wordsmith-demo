{
  // Required arguments for this template
  /* shard:: error "shard must be specified", */
  name:: error "name must be specified",

  // Optional arguments for this template.
  labels:: {},

  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: $.name,
    labels+: $.labels + {
      app: $.name,
    },
  },
  rules: error "name must be specified",
}
