#!/bin/bash

# List of instance names and corresponding regions
instances=("asasikumar-ddos-asia" "asasikumar-ddos-us" "asasikumar-ddos-europe")
regions=("asia-northeast1-b" "northamerica-northeast1-a" "europe-west1-b")

# Command to execute on each instance
command="sudo docker run -v /tmp:/tmp/report wallarm/gotestwaf --url=https://www.example.com"

# Create an array to store process IDs
pids=()

# Loop through instances and run the command in the background
for i in "${!instances[@]}"; do
  instance="${instances[$i]}"
  region="${regions[$i]}"

  # Check if Docker is running
  ssh "$instance" --zone "$region" --command "docker ps" >/dev/null 2>&1  &> /dev/null

  # If exit code is non-zero (not running), start Docker daemon
  if [[ $? -ne 0 ]]; then
    echo "Starting Docker daemon on $instance..."
    ssh "$instance" --zone "$region" --command "sudo systemctl start docker" &> /dev/null
  fi

  # Run the main command with a short delay to allow Docker start (if needed)
  sleep 5  # Adjust delay as needed
  gcloud compute ssh "$instance" --zone "$region" --command "$command" &
  pids+=($!)
done

# Wait for all background processes to complete
for pid in "${pids[@]}"; do
  wait $pid
done
