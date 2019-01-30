# Configure the New Relic provider

# Adapted from https://www.terraform.io/docs/providers/newrelic/index.html

provider "newrelic" {
  api_key = "${var.newrelic_api_key}"
  version = "~> 1.2"
}

# Create an alert policy
resource "newrelic_alert_policy" "alert" {
  name = "Alert"
}

# Add a condition
resource "newrelic_alert_condition" "spin-appdex" {
  policy_id = "${newrelic_alert_policy.alert.id}"

  name        = "spin-appdex"
  type        = "apm_app_metric"
  entities    = ["179953338"]                                       # You can look this up in New Relic
  metric      = "apdex"
  runbook_url = "https://github.com/devops-infra-demo/wiki/runbook"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }

  count = "${length(var.newrelic_apm_entities) > 0 ? 1 : 0}"
}

# Add a notification channel
resource "newrelic_alert_channel" "email" {
  name = "email"
  type = "email"

  configuration = {
    recipients              = "richard+devops.infra.demo@moduscreate.com"
    include_json_attachment = "1"
  }

  count = "${length(var.newrelic_alert_email) > 0 ? 1 : 0}"
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id  = "${newrelic_alert_policy.alert.id}"
  channel_id = "${newrelic_alert_channel.email.id}"

  count = "${length(var.newrelic_alert_email) > 0 ? 1 : 0}"
}
