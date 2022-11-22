vault {
  renew_token = false
}

log_level = "info"
wait = "1s:45s"
pid_file = "/var/run/consul-template.pid"

deduplicate {
  enabled = true
  prefix = "consul-template/dedup/"
}