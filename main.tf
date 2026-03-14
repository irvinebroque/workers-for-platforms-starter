terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.18.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "app_gateway" {
  filter = {
    name = var.zone_name
    account = {
      id = var.account_id
    }
  }
}

resource "cloudflare_worker" "app_gateway" {
  account_id = var.account_id
  name       = "app-gateway"
  depends_on = [cloudflare_workers_for_platforms_dispatch_namespace.apps]

  observability = {
    enabled = true
    logs = {
      enabled         = true
      invocation_logs = true
    }
  }
}

resource "cloudflare_workers_for_platforms_dispatch_namespace" "apps" {
  account_id = var.account_id
  name       = "apps"
}

resource "cloudflare_worker_version" "app_gateway" {
  account_id         = var.account_id
  worker_id          = cloudflare_worker.app_gateway.id
  compatibility_date = "2026-03-13"
  main_module        = "index.js"

  modules = [{
    name         = "index.js"
    content_type = "application/javascript+module"
    content_file = "${path.module}/build/index.js"
  }]

  bindings = [{
    name      = "APPS"
    type      = "dispatch_namespace"
    namespace = cloudflare_workers_for_platforms_dispatch_namespace.apps.name
  }]
}

resource "cloudflare_workers_deployment" "app_gateway" {
  account_id  = var.account_id
  script_name = cloudflare_worker.app_gateway.name
  strategy    = "percentage"

  versions = [{
    version_id = cloudflare_worker_version.app_gateway.id
    percentage = 100
  }]
}

resource "cloudflare_dns_record" "apps_wildcard" {
  zone_id = data.cloudflare_zone.app_gateway.id
  name    = "*"
  ttl     = 1
  type    = "A"
  content = "192.0.2.0"
  proxied = true
}

resource "cloudflare_workers_route" "app_gateway" {
  zone_id    = data.cloudflare_zone.app_gateway.id
  pattern    = "*.${var.zone_name}/*"
  script     = cloudflare_worker.app_gateway.name
  depends_on = [cloudflare_workers_deployment.app_gateway]
}

resource "cloudflare_zero_trust_access_policy" "app_gateway_email_otp" {
  account_id = var.account_id
  name       = "apps-email-otp"
  decision   = "allow"

  include = [{
    email_domain = {
      domain = var.access_email_domain
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "app_gateway" {
  zone_id = data.cloudflare_zone.app_gateway.id
  name    = "app-gateway-apps"
  domain  = "*.${var.zone_name}/*"
  type    = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.app_gateway_email_otp.id
    precedence = 1
  }]
}
