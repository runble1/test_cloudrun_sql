provider "google" {
  project     = var.project
  credentials = var.credentials
  region      = var.region
}