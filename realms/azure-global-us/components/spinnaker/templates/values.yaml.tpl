halyard:
  spinnakerVersion: 1.16.1
  image:
    repository: gcr.io/spinnaker-marketplace/halyard
    tag: 1.23.2
    # tag: 1.28.0
  # Set to false to disable persistence data volume for halyard
  persistence:
    enabled: true
  # Provide a config map with Hal commands that will be run the core config (storage)
  # The config map should contain a script in the config.sh key
  additionalScripts:
    # enabled: false
    #configMapName: my-halyard-config
    #configMapKey: config.sh
    # If you'd rather do an inline script, set create to true and put the content in the data dict like you would a configmap
    # The content will be passed through `tpl`, so value interpolation is supported.
    create: true
    #data: {}
    data:
      # enable_artifact_feature: |-
      #   echo "Enabling artifacts feature"
      #   $HAL_COMMAND config features edit --artifacts true
      # enable_gitrepo_artifact.sh: |-
      #   echo "Enabling gitrepo artifact"
      #   $HAL_COMMAND config artifact gitrepo enable
      #   $HAL_COMMAND config artifact gitrepo account add azure-devops --token dia5u5yrqba6k2hik3r4bb5njg7ulvltp4lsjw5ysebqza4ssp4a
      enable_http_artifact.sh: |-
        echo "Enabling http artifact"
        $HAL_COMMAND config artifact http enable
      # apply.sh: |-
      #   echo "Apply changes"
      #   $HAL_COMMAND deploy apply
  additionalSecrets:
    create: false
    data: {}
    ## Uncomment if you want to use a pre-created secret rather than feeding data in via helm.
    # name:
  additionalConfigMaps:
    create: false
    data: {}
    ## Uncomment if you want to use a pre-created ConfigMap rather than feeding data in via helm.
    # name:
  ## Define custom profiles for Spinnaker services. Read more for details:
  ## https://www.spinnaker.io/reference/halyard/custom/#custom-profiles
  ## The contents of the files will be passed through `tpl`, so value interpolation is supported.
  additionalProfileConfigMaps:
    # data: {}
      ## if you're running spinnaker behind a reverse proxy such as a GCE ingress
      ## you may need the following profile settings for the gate profile.
      ## see https://github.com/spinnaker/spinnaker/issues/1630
      ## otherwise its harmless and will likely become default behavior in the future
      ## According to the linked github issue.
      # gate-local.yml:
      #   server:
      #     tomcat:
      #       protocolHeader: X-Forwarded-Proto
      #       remoteIpHeader: X-Forwarded-For
      #       internalProxies: .*
      #       httpsServerPort: X-Forwarded-Port
    data:
      echo-local.yaml:
        mail:
          enabled: true
          host: ${smtp-host}
          from: ${smtp-from-email}
          properties:
            mail:
                smtp:
                  auth: true
                  starttls:
                    enable: true
        spring:
          mail:
            host: ${smtp-host}
            username: ${smtp-username}
            password: ${smtp-password}
            port: 587
            properties:
              mail:
                smtp:
                  auth: true
                  starttls:
                    enable: true
                transport:
                  protocol: smtp
                debug: true

  ## Define custom settings for Spinnaker services. Read more for details:
  ## https://www.spinnaker.io/reference/halyard/custom/#custom-service-settings
  ## You can use it to add annotations for pods, override the image, etc.
  additionalServiceSettings: {}
    # deck.yml:
    #   artifactId: gcr.io/spinnaker-marketplace/deck:2.9.0-20190412012808
    #   kubernetes:
    #     podAnnotations:
    #       iam.amazonaws.com/role: <role_arn>
    # clouddriver.yml:
    #   kubernetes:
    #     podAnnotations:
    #       iam.amazonaws.com/role: <role_arn>

  ## Populate to provide a custom local BOM for Halyard to use for deployment. Read more for details:
  ## https://www.spinnaker.io/guides/operator/custom-boms/#boms-and-configuration-on-your-filesystem
  bom: ~
  #   artifactSources:
  #     debianRepository: https://dl.bintray.com/spinnaker-releases/debians
  #     dockerRegistry: gcr.io/spinnaker-marketplace
  #     gitPrefix: https://github.com/spinnaker
  #     googleImageProject: marketplace-spinnaker-release
  #   services:
  #     clouddriver:
  #       commit: 031bcec52d6c3eb447095df4251b9d7516ed74f5
  #       version: 6.3.0-20190904130744
  #     deck:
  #       commit: b0aac478e13a7f9642d4d39479f649dd2ef52a5a
  #       version: 2.12.0-20190916141821
  #     ...
  #   timestamp: '2019-09-16 18:18:44'
  #   version: 1.16.1

  ## Uncomment if you want to add extra commands to the init script
  ## run by the init container before halyard is started.
  ## The content will be passed through `tpl`, so value interpolation is supported.
  # additionalInitScript: |-

  ## Uncomment if you want to add annotations on halyard and install-using-hal pods
  # annotations:
  #   iam.amazonaws.com/role: <role_arn>

  ## Uncomment the following resources definitions to control the cpu and memory
  # resources allocated for the halyard pod
  resources:
    requests:
      memory: "4Gi"
      cpu: "100m"
    # limits:
    #   memory: "2Gi"
    #   cpu: "200m"

  ## Uncomment if you want to set environment variables on the Halyard pod.
  # env:
  #   - name: JAVA_OPTS
  #     value: -Dhttp.proxyHost=proxy.example.com
  customCerts:
    ## Enable to override the default cacerts with your own one
    enabled: false
    secretName: custom-cacerts

# Define which registries and repositories you want available in your
# Spinnaker pipeline definitions
# For more info visit:
#   https://www.spinnaker.io/setup/providers/docker-registry/

# Configure your Docker registries here
dockerRegistries:
- name: dockerhub
  address: index.docker.io
  repositories:
    - library/alpine
    - library/ubuntu
    - library/centos
    - library/nginx
- name: acr
  # address: sapience.azurecr.io
  # username: sapience  
  # password: 'S=A8bcw7zeGezpzO4Mj9smthLgXy3pEU'
  # email: devops@sapience.net
  address: ${acr-address}
  username: ${acr-username}
  password: ${acr-password}
  email: ${acr-email}
# - name: gcr
#   address: https://gcr.io
#   username: _json_key
#   password: '<INSERT YOUR SERVICE ACCOUNT JSON HERE>'
#   email: 1234@5678.com

# If you don't want to put your passwords into a values file
# you can use a pre-created secret instead of putting passwords
# (specify secret name in below `dockerRegistryAccountSecret`)
# per account above with data in the format:
# <name>: <password>

# dockerRegistryAccountSecret: myregistry-secrets

kubeConfig:
  # Use this when you want to register arbitrary clusters with Spinnaker
  # Upload your ~/kube/.config to a secret
  enabled: true
  secretName: kubeconfig
  secretKey: config
  # Use this when you want to configure halyard to reference a kubeconfig from s3
  # This allows you to keep your kubeconfig in an encrypted s3 bucket
  # For more info visit:
  #   https://www.spinnaker.io/reference/halyard/secrets/s3-secrets/#secrets-in-s3
  # encryptedKubeconfig: encrypted:s3!r:us-west-2!b:mybucket!f:mykubeconfig
  # List of contexts from the kubeconfig to make available to Spinnaker
  contexts:
  - ${realm}
  ${additional-kubeconfig-contexts}
  deploymentContext: ${realm}
  omittedNameSpaces:
  - kube-system
  - kube-public
  onlySpinnakerManaged:
    enabled: false

  # When false, clouddriver will skip the permission checks for all kubernetes kinds at startup.
  # This can save a great deal of time during clouddriver startup when you have many kubernetes
  # accounts configured. This disables the log messages at startup about missing permissions.
  checkPermissionsOnStartup: true

  # A list of resource kinds this Spinnaker account can deploy to and will cache.
  # When no kinds are configured, this defaults to ???all kinds'.
  # kinds:
  # -

  # A list of resource kinds this Spinnaker account cannot deploy to or cache.
  # This can only be set when ???kinds is empty or not set.
  # omittedKinds:
  # -

# Change this if youd like to expose Spinnaker outside the cluster
ingress:
  enabled: true
  host: spinnaker.${dns_realm}.${region}.${cloud}.sapienceanalytics.com
  annotations:
    ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/whitelist-source-range: ${whitelist-source-range}
    certmanager.k8s.io/acme-challenge-type: dns01
    certmanager.k8s.io/acme-dns01-provider: azure-dns
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
  tls:
  - secretName: spinnaker-certs
    hosts:
    - spinnaker.${dns_realm}.${region}.${cloud}.sapienceanalytics.com
    - spinnaker.sapienceanalytics.com

ingressGate:
  enabled: false
  # host: gate.spinnaker.example.org
  # annotations:
    # ingress.kubernetes.io/ssl-redirect: 'true'
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  # tls:
  #  - secretName: -tls
  #    hosts:
  #      - domain.com

# spinnakerFeatureFlags is a list of Spinnaker feature flags to enable
# Ref: https://www.spinnaker.io/reference/halyard/commands/#hal-config-features-edit
# spinnakerFeatureFlags:
#   - artifacts
#   - pipeline-templates
spinnakerFeatureFlags:
  - artifacts
  - jobs

# Node labels for pod assignment
# Ref: https://kubernetes.io/docs/user-guide/node-selection/
# nodeSelector to provide to each of the Spinnaker components
nodeSelector: {}

# Redis password to use for the in-cluster redis service
# Enable redis to use in-cluster redis
redis:
  enabled: true
  # External Redis option will be enabled if in-cluster redis is disabled
  external:
    host: "<EXTERNAL-REDIS-HOST-NAME>"
    port: 6379
    # password: ""
  password: password
  nodeSelector: {}
  cluster:
    enabled: false
# Uncomment if you don't want to create a PVC for redis
#  master:
#    persistence:
#      enabled: false

# Minio access/secret keys for the in-cluster S3 usage
# Minio is not exposed publically
minio:
  enabled: false
  imageTag: RELEASE.2019-02-13T19-48-27Z
  serviceType: ClusterIP
  accessKey: spinnakeradmin
  secretKey: spinnakeradmin
  bucket: "spinnaker"
  nodeSelector: {}
# Uncomment if you don't want to create a PVC for minio
#  persistence:
#    enabled: false

# Google Cloud Storage
gcs:
  enabled: false
  project: my-project-name
  bucket: "<GCS-BUCKET-NAME>"
  ## if jsonKey is set, will create a secret containing it
  jsonKey: '<INSERT CLOUD STORAGE JSON HERE>'
  ## override the name of the secret to use for jsonKey, if `jsonKey`
  ## is empty, it will not create a secret assuming you are creating one
  ## external to the chart. the key for that secret should be `key.json`.
  secretName:

# AWS Simple Storage Service
s3:
  enabled: false
  bucket: "<S3-BUCKET-NAME>"
  # rootFolder: "front50"
  # region: "us-east-1"
  # endpoint: ""
  # accessKey: ""
  # secretKey: ""

# Azure Storage Account
azs:
  enabled: true
  storageAccountName: "${storageAccountName}"
  accessKey: "${accessKey}"
  containerName: "spinnaker"

rbac:
  # Specifies whether RBAC resources should be created
  create: true

serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccounts to use.
  # If left blank it is auto-generated from the fullname of the release
  halyardName:
  spinnakerName:
securityContext:
  # Specifies permissions to write for user/group
  runAsUser: 1000
  fsGroup: 1000
#