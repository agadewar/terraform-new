resource "kubernetes_config_map" "apim" {
  metadata {
    name      = "apim"
    namespace = local.namespace
  }

  data = {
      #APIM Open-API
      "ApimConfiguration__AccessToken"    = "SharedAccessSignature integration&202012030909&jT8k29wFB9QnsQ0l6iLhLU0rI9Bw0A1dHxxi8nWs5KfKLXCmKXlA4gClGnS5/xKaeD530IDdrz1SEJQUo/JiMw=="
      "ApimConfiguration__AzureApiUri"    = "https://sapience-lab-us-demo.management.azure-api.net"
      "ApimConfiguration__DelegationKey"  = "aW50ZWdyYXRpb24mMjAyMDEyMDIwNjA2JjkyWDV4VWlRdnlFdnBQaWhhU1FzLytucXZlZGJGRitTK0E1Qm1KWHdhT2F3bHlDV1BqUEJaRlI1eUJPYkd0bGljY3U1YmkwTVBwaWZrL2JnY2VoOFl3PT0="
      "ApimConfiguration__HomeUrl"        = "https://sapience-lab-us-demo.developer.azure-api.net"
      "ApimConfiguration__ResourceGroup"  = var.resource_group_name
      "ApimConfiguration__ServiceName"    = "sapience-lab-us-demo"
      "ApimConfiguration__SubscriptionId" = var.subscription_id
      "ApimConfiguration__ClientId"       = "qkutFleOiF3VKuGEmsHRRODrxgC7lMJA"
      "ApimConfiguration__ClientSecret"   = "DKODY-TfCVKhLaNtOEsvqa0iYNJ66O670WPn5KPV4vAVqvqCf2ZBtXriTesgt8w1"
      "ApimConfiguration__Authority"      = "https://sapience-lab-us-demo.auth0.com"
      
  }
}
