terraform {
  backend "gcs" {
    bucket = "briananderson-xyz-dev-tf-state"
    prefix = "dns/dev"
  }
}
