{
  //required
  name:: error "name must be specified",
  selector:: error "selector must be specified",
  ports:: error "ports must be specified",

  // optional
  labels:: {},
  type:: "ClusterIP",

  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: $.name,
    labels+: $.labels + {
      // default labels
      app: $.name,
    },
  },
  spec: {
    type: $.type,
    ports: $.ports,
    selector: $.selector,
  }
}
