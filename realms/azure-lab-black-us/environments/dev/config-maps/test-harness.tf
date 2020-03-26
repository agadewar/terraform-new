resource "kubernetes_config_map" "test_harness" {
  metadata {
    name      = "test-harness"
    namespace = local.namespace
  }

  data = {
      "args": "-genusers=false -userspath=/opt/sapience/activitycollectortestharness/users.dat -numdays=1 -numusers=50 -mode=simulation"
  }
}