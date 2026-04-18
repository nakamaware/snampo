import base64
import json
import os

import requests

TEAM_ROLE_MENTION = os.getenv("TEAM_ROLE_MENTION")
PROJECT_NAME = os.getenv("PROJECT_NAME")
WEBHOOK_URL = os.getenv("WEBHOOK_URL")


def notify_discord(data, context):
    # https://cloud.google.com/billing/docs/how-to/budgets-programmatic-notifications#notification_format
    try:
        notification_data = json.loads(base64.b64decode(data["data"]).decode("utf-8"))
    except (KeyError, ValueError) as e:
        print(f"Failed to parse Pub/Sub message: {e}")
        return

    alert_threshold_exceeded = notification_data.get("alertThresholdExceeded")
    if alert_threshold_exceeded is None:
        # 閾値未超過の定期更新通知は無視
        return

    cost_amount = notification_data.get("costAmount", 0)
    budget_amount = notification_data.get("budgetAmount", 0)
    currency_code = notification_data.get("currencyCode", "USD")

    if alert_threshold_exceeded >= 1.0:
        title = f"{PROJECT_NAME} の予算を使い切りました"
        description = "GCP の予算上限に達しました。利用状況を確認してください。"
    else:
        title = f"{PROJECT_NAME} の予算の {alert_threshold_exceeded * 100:.0f}% に達しました"
        description = "GCP の予算アラートが発生しました。利用状況を確認してください。"

    message = {
        "content": TEAM_ROLE_MENTION,
        "embeds": [
            {
                "title": title,
                "description": description,
                "color": 0xFF0000,
                "fields": [
                    {
                        "name": "使用額",
                        "value": f"{cost_amount} {currency_code}",
                        "inline": True,
                    },
                    {
                        "name": "予算額",
                        "value": f"{budget_amount} {currency_code}",
                        "inline": True,
                    },
                ],
            }
        ],
    }

    response = requests.post(
        WEBHOOK_URL,
        json=message,
        timeout=10,
    )

    if 200 <= response.status_code < 300:
        print("Successfully sent message to Discord")
    else:
        print(f"Failed to send message to Discord: {response.status_code} {response.text}")
        response.raise_for_status()
