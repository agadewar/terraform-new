apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt${suffix}
spec:
  acme:
    server: ${letsencrypt_server}
    email: ${email}
    privateKeySecretRef:
      name: letsencrypt${suffix}
    # use dns-01 challenges in order to support wildcard domain names
    solvers:
    - dns01:
        azuredns:
          # email: ${email}
          # service principal client id
          clientID: ${service_principal_client_id}
          # secret with the password
          clientSecretSecretRef:
            name: ${service_principal_password_secret_ref}
            key: password
          # name of the DNS Zone
          hostedZoneName: ${dns_zone_name}
          # resource group where the DNS Zone is located
          resourceGroupName: ${resource_group_name}
          subscriptionID: ${subscription_id}
          tenantID: ${service_pricincipal_tenant_id}
          environment: AzurePublicCloud
