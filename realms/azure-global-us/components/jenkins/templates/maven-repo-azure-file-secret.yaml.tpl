apiVersion: v1
kind: Secret
metadata:
  name: azure-secret
type: Opaque
data:
  azurestorageaccountname: ${azurestorageaccountname}
  azurestorageaccountkey: ${azurestorageaccountkey}