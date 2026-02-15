terraform {
  backend "gcs" {
    bucket       = "briananderson-xyz-tf-state"
    prefix       = "dns/prod"
    use_lockfile = true
  }
}
