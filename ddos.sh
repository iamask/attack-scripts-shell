#!/bin/bash

instances=("asasikumar-ddos-asia" "asasikumar-ddos-us" "asasikumar-ddos-europe")
regions=("asia-northeast1-b" "northamerica-northeast1-a" "europe-west1-b")


# JMX file (replace with your test plan file)
jmx_file="attack.jmx"

run_jmeter_on_instance() {
  local instance_name="$1"
  local region="$2"
  #gcloud compute ssh "$instance_name" --zone "$region" --command "sudo apt update && sudo apt install -y jmeter"
  #gcloud compute ssh "$instance_name" --zone "$region" --command "sudo apt update && sudo apt install -y jmeter"
  #gcloud compute scp "$jmx_file" "$instance_name:~/$jmx_file" --zone "$region"
  gcloud compute ssh "$instance_name" --zone "$region" --command "jmeter -n -t ~/$jmx_file"
}

# Run JMeter tests on each VM parallely
for i in "${!instances[@]}"; do
  run_jmeter_on_instance "${instances[$i]}" "${regions[$i]}" &
done

# Wait for all background processes to complete
wait

# You can add commands to collect and transfer result files if needed