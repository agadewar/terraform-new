---
apiVersion: v1
kind: Service
metadata:
  labels:
    service: ambassador-admin
  name: ambassador-admin
spec:
  type: NodePort
  ports:
  - name: ambassador-admin
    port: 8877
    targetPort: 8877
  selector:
    service: ambassador
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: ambassador
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - services
  - secrets
  verbs: ["get", "list", "watch"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ambassador
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: ambassador
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ambassador
subjects:
- kind: ServiceAccount
  name: ambassador
  namespace: default
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ambassador
spec:
  replicas: ${replicas}
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"
        "consul.hashicorp.com/connect-inject": "false"
      labels:
        service: ambassador
    spec:
      serviceAccountName: ambassador
      containers:
      - name: ambassador
        image: quay.io/datawire/ambassador:0.50.3
        resources:
          limits:
            cpu: 1
            memory: 400Mi
          requests:
            cpu: 200m
            memory: 100Mi
        env:
          # https://www.getambassador.io/reference/running/#namespaces
        - name: AMBASSADOR_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: AMBASSADOR_SINGLE_NAMESPACE
          value: "true"
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
        - name: admin
          containerPort: 8877
        livenessProbe:
          httpGet:
            path: /ambassador/v0/check_alive
            port: 8877
          initialDelaySeconds: 30
          periodSeconds: 3
        readinessProbe:
          httpGet:
            path: /ambassador/v0/check_ready
            port: 8877
          initialDelaySeconds: 30
          periodSeconds: 3
      restartPolicy: Always
