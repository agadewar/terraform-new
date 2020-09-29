apiVersion: v1
kind: ServiceAccount
metadata:
  name: sapience-deploy
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: sapience-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: sapience-deploy
  namespace: ${namespace}
--- 