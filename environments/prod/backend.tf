terraform {
  backend "gcs" {
    bucket      = "briananderson-xyz-tf-state"
    prefix      = "dns/prod"
  }
}
