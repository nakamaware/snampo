# ------------------------------
# 変数
# ------------------------------

variable "billing_account_id" {
  type        = string
  description = "GCP 請求先アカウント ID"
  sensitive   = true
}

variable "discord_role_id" {
  type        = string
  description = "Discord のロール ID (数字のみ)"
}

variable "discord_webhook_url" {
  type        = string
  description = "Discord の Webhook URL"
  sensitive   = true
}

# ------------------------------
# 予算アラート
# ------------------------------

data "google_billing_account" "account" {
  billing_account = var.billing_account_id
}

resource "google_monitoring_notification_channel" "email" {
  project = local.project_id

  display_name = "Budget Alert (gcp-organization-developers)"
  type         = "email"
  labels = {
    email_address = "gcp-organization-developers@nakamaware.com"
  }
}

resource "google_pubsub_topic" "budget_notifications" {
  name    = "budget-notifications"
  project = local.project_id
}

resource "google_billing_budget" "budget" {
  billing_account = data.google_billing_account.account.id
  display_name    = "Billing Budget for ${local.project_name}"

  budget_filter {
    projects = ["projects/${local.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "50"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email.id,
    ]
    disable_default_iam_recipients = true
    pubsub_topic                   = google_pubsub_topic.budget_notifications.id
  }
}

# ------------------------------
# Discord Webhook URL の Secret Manager 管理
# ------------------------------

resource "google_secret_manager_secret" "discord_webhook" {
  project   = local.project_id
  secret_id = "discord-webhook-url"

  replication {
    user_managed {
      replicas {
        location = local.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "discord_webhook" {
  secret      = google_secret_manager_secret.discord_webhook.id
  secret_data = var.discord_webhook_url
}

# ------------------------------
# Cloud Functions 用サービスアカウント
# ------------------------------

resource "google_service_account" "budget_notifier" {
  project      = local.project_id
  account_id   = "budget-notifier"
  display_name = "Budget Notifier Cloud Function SA"
}

resource "google_secret_manager_secret_iam_member" "budget_notifier_webhook_accessor" {
  project   = local.project_id
  secret_id = google_secret_manager_secret.discord_webhook.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.budget_notifier.email}"
}

# ------------------------------
# 通知用 Cloud Functions
# ------------------------------

data "archive_file" "budget_notifier" {
  type        = "zip"
  source_dir  = "${path.root}/../../../functions/budget-notifier"
  output_path = "${path.root}/sources/budget-notifier.zip"
}

resource "google_storage_bucket" "budget_notifier" {
  project       = local.project_id
  name          = "${local.project_id}-budget-notifier"
  location      = local.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_object" "budget_notifier" {
  name   = "budget-notifier.${data.archive_file.budget_notifier.output_md5}.zip"
  bucket = google_storage_bucket.budget_notifier.name
  source = data.archive_file.budget_notifier.output_path
}

resource "google_cloudfunctions_function" "budget_notifier" {
  project = local.project_id
  name    = "budget-notifier"
  runtime = "python311"

  available_memory_mb   = 256
  service_account_email = google_service_account.budget_notifier.email
  source_archive_bucket = google_storage_bucket.budget_notifier.name
  source_archive_object = google_storage_bucket_object.budget_notifier.name
  entry_point           = "notify_discord"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.budget_notifications.name
  }

  secret_environment_variables {
    key        = "WEBHOOK_URL"
    project_id = local.project_id
    secret     = google_secret_manager_secret.discord_webhook.secret_id
    version    = "latest"
  }

  environment_variables = {
    TEAM_ROLE_MENTION = "<@&${var.discord_role_id}>"
    PROJECT_NAME      = local.project_name
  }
}
