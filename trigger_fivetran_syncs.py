import time
import requests
import subprocess
from requests.auth import HTTPBasicAuth

# ==== Fivetran Credentials ====
auth = HTTPBasicAuth("TUnxKg52yk99zfmu", "9V3lY8tOOuEVA7odLynfX1J4hg3zmoUu")

# ==== Your Connector IDs ====
connectors = [
    "theories_arbitrate",  # customers
    "happy_pushy",         # subscriptions
    "wrath_whose",         # expenses
    "diner_cation"         # marketing_spend
]

# ==== Trigger + Monitor ====
def trigger_and_monitor_sync(connector_id, timeout_minutes=5):
    print(f"\n🚀 Triggering sync for {connector_id}")
    trigger_url = f"https://api.fivetran.com/v1/connectors/{connector_id}/force"
    status_url = f"https://api.fivetran.com/v1/connectors/{connector_id}"

    # Trigger sync
    r = requests.post(trigger_url, auth=auth)
    if r.status_code != 200:
        print(f"❌ Failed to trigger {connector_id}: {r.json()}")
        return False

    # Monitor
    start_time = time.time()
    while True:
        time.sleep(10)
        r = requests.get(status_url, auth=auth)
        sync_state = r.json()["data"]["status"]
        print(f"⏳ {connector_id} status: {sync_state}")

        if sync_state == "succeeded":
            print(f"✅ {connector_id} sync completed")
            return True
        elif sync_state == "failed":
            print(f"❌ {connector_id} sync failed")
            return False
        elif time.time() - start_time > timeout_minutes * 60:
            print(f"⏰ Timeout waiting for {connector_id}")
            return False

# ==== Run DBT ====
def run_dbt():
    try:
        subprocess.run(["dbt", "run"], check=True)
        subprocess.run(["dbt", "test"], check=True)
        print("\n✅ DBT run and test completed.")
        return True
    except subprocess.CalledProcessError:
        print("\n❌ DBT failed.")
        # Optional: alert logic here
        send_alert()
        return False

# ==== Send Alert (You can replace with email, Slack, Discord etc) ====
def send_alert():
    print("🚨 Alert: DBT test failed! Send notification here.")
    # Example: send email, Slack, Discord, webhook, etc.

# ==== Main ====
if __name__ == "__main__":
    print("🚦 Starting Fivetran sync + DBT pipeline\n")
    all_success = True

    for connector in connectors:
        if not trigger_and_monitor_sync(connector):
            all_success = False

    if all_success:
        print("\n🎯 All syncs succeeded. Kicking off DBT...")
        run_dbt()
    else:
        print("\n❌ Skipping DBT. Some syncs failed.")
