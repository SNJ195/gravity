#!/bin/bash

# Set variables

PROJECT_ID="devops-2024"

ZONE="us-central1-a"

ALERT_POLICY_NAME="High CPU Usage Alert"

EMAIL_ADDRESS="admin@gravityer.com"

# List of instances to monitor

INSTANCES=(" web-server-instance" , "Jenkins-server")

# Authenticate with Google Cloud

gcloud auth login

# Set the current project

gcloud config set project $PROJECT_ID

# Enable required APIs

gcloud services enable monitoring.googleapis.com

# Install the monitoring agent on each instance

for INSTANCE in "${INSTANCES[@]}"; do

echo "Installing monitoring agent on $INSTANCE..."

gcloud compute ssh $INSTANCE --zone=$ZONE --command="curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && sudo bash add-monitoring-agent-repo.sh && sudo apt-get update && sudo apt-get install -y stackdriver-agent"

done

# Set up notification channel

NOTIFICATION_CHANNEL_ID=$(gcloud monitoring channels create \

--display-name="Email Notification" \

--description="Email notification for CPU usage alert" \

--type="email" \

--channel-labels=from_address="no-reply@google.com",to_address="$EMAIL_ADDRESS" \

--format="value(name)")

# Create a monitoring metric and alert policy for each instance

for INSTANCE in "${INSTANCES[@]}"; do

echo "Creating monitoring policy for $INSTANCE..."

gcloud beta monitoring policies create \

--display-name="$ALERT_POLICY_NAME for $INSTANCE" \

--conditions="[

{

\"displayName\": \"CPU usage exceeds 80% for $INSTANCE\",

\"conditionThreshold\": {

\"filter\": \"metric.type=\\\"compute.googleapis.com/instance/cpu/utilization\\\" resource.type=\\\"gce_instance\\\" resource.label.instance_id=\\\"$(gcloud compute instances describe $INSTANCE --zone=$ZONE --format='value(id)')\\\"\",

\"comparison\": \"COMPARISON_GT\",

\"thresholdValue\": 0.8,

\"duration\": \"60s\",

\"trigger\": {\"count\": 1}

}

}

]" \

--notification-channels="$NOTIFICATION_CHANNEL_ID"

done

echo "Google Cloud Monitoring setup complete. Alerts will be sent to $EMAIL_ADDRESS if CPU usage exceeds 80% on any of the specified instances."
