locals {
  cloudsql_name = "quickstart-instance"
}

resource "google_cloud_run_service" "default" {
  name     = local.cloudsql_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/run-sql"
        env {
          name  = "INSTANCE_UNIX_SOCKET"
          value = "/cloudsql/${var.project}:${var.region}:${local.cloudsql_name}"
        }
        env {
          name  = "DB_NAME"
          value = google_sql_database.database.name
        }
        env {
          name  = "DB_USER"
          value = google_sql_user.users.name
        }
        env {
          name  = "DB_PASS"
          value = google_sql_user.users.password
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }
  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}