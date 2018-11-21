// utils.libsonnet
{
  pairList(tab,
           kfield='name',
           vfield='value'):: [
    { [kfield]: k, [vfield]: tab[k] }
    for k in std.objectFields(tab)
  ],

  namedObjectList(tab, name_field='name'):: [
    tab[name] { [name_field]: name }
    for name in std.objectFields(tab)
  ],

  // makes a kubernetes `List` v1 object from the top level keys
  // of the specified `obj`
  //
  // Input:
  // { configMap: {"apiVersion": "v1", "kind": "Deployment",... },
  // {"kind": "Service"} }
  kubeList(obj):: {
    apiVersion: "v1",
    kind: "List",
    items: [obj[x] for x in std.objectFields(obj)]
  },

  // takes the objects in the specified obj and returns them as array
  objKeysToArray(obj):: [obj[x] for x in std.objectFields(obj)],


  // creates a merged `List` v1 of kubernetes objects
  //
  // Input: [cm,prometheus]
  //        cm: {configmap: {apiVersion: v1, Kind: Configmap, ...}}
  kubeListArray(objList):: {
    apiVersion: "v1",
    kind: "List",
    items: [$.objKeysToArray(x) for x in objList][0],
    /* itemList: std.map($.objKeysToArray(x), objList) */
    /* items: std.flattenArrays(self.itemList[0]) */
   },

   kubeListUni(obj)::
     if std.type(obj) == "object" then {
       apiVersion: "v1",
       kind: "List",
       items: [obj[x] for x in std.objectFields(obj)]
     } else if std.type(obj) == "array" then {
       local objKeysToArray(obj) = [
           [obj[x] for x in std.objectFields(obj)]
       ],
       apiVersion: "v1",
       kind: "List",
       itemList:: [self.objKeysToArray(x) for x in obj],
       list: std.flattenArrays(self.itemList)
     },

  // makes the same as above but "flattens" the returned array to
  // one unified `List` object
  flattenKubeList(objList):: {
    kind: "List",
    items: std.flattenArrays($.kubeList(objList)),
  },
}
