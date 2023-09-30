# Creates a private key in PEM format
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Creates an account on the ACME server using the private key and an email
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email
  # external_account_binding {
  #   key_id      = var.account_id
  #   hmac_base64 = base64encode(var.hmac)
  # }
}

# Gets a certificate from the ACME server
resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.reg.account_key_pem
  min_days_remaining        = var.min_days_renewal
  preferred_chain           = var.preferred_chain
  subject_alternative_names = var.subdomains
  common_name               = var.domain
  certificate_p12_password  = ""

  dns_challenge {
    config   = var.dns_challenge_params
    provider = var.dns_provider
  }
}
