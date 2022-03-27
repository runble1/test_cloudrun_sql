resource "google_sql_database_instance" "instance" {
  name             = "quickstart-instance"
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"
  }

  # テスト用なので削除できるように
  deletion_protection = "false"
}

resource "google_sql_database" "database" {
  name     = "quickstart_db"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "quickstart-user"
  instance = google_sql_database_instance.instance.name
  host     = "%"
  password = "testtest"
}