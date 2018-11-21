{
  // required
  name:: error "name must be specified",

  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: $.name
  },
  data: error "data must be specified",
}
