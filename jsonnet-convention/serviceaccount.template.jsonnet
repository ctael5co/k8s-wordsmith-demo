{
  // required
  name:: error "name must be specified",

  // Optional arguments for this template.
  labels:: {},

  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: $.name,
    labels+: $.labels + {
      app: $.name,
    },
  },
}
