variable "account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token."
  sensitive   = true
}

variable "zone_name" {
  type        = string
  description = "Cloudflare zone name used for custom domain, e.g. example.com."
}

variable "access_email_domain" {
  type        = string
  description = "Email domain allowed by Access policy, e.g. cloudflare.com."
}
