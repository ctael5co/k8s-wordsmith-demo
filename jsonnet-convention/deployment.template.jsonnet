local utils = import 'utils.libsonnet';

{
  // required
  name:: error "name must be specified",
  dockerImage:: error "dockerImage must be specified",
  shard:: error "shard must be specified",


  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: $.name,
    /* labels+: $.labels + {
      // default labels
      app: $.shard,
    }, */
  },
  spec: {
    replicas: 1,
    template: {
      metadata: {
        name: $.name,
        labels: {
          name: $.name,
        },
      },
      /* spec: {
        containersObj:: {
          prometheus: {
            name: $.name,
            image: $.dockerImage,
          },
        },
        containers: utils.namedObjectList(self.containersObj), */
      spec: {
        containers: [
          {
            name: $.name,
            image: $.dockerImage
          },
        ],
      },
    }
  }
}
