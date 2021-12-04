import Config

# https://github.com/deadtrickster/prometheus-httpd/blob/master/doc/prometheus_httpd.md
config :prometheus, :prometheus_http,
  path: String.to_charlist("/metrics"),
  format: :auto,
  port: 8081
