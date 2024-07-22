#!/bin/bash

# List of instance names and corresponding regions
instances=("asasikumar-ddos-asia" "asasikumar-ddos-us" "asasikumar-ddos-europe")
regions=("asia-northeast1-b" "northamerica-northeast1-a" "europe-west1-b")

#Command to execute on each instance
#command="sudo docker pull wallarm/gotestwaf"

command="sudo docker run -v /tmp:/tmp/report wallarm/gotestwaf --url=https://www.example.com"

# Create an array to store process IDs
pids=()

# Loop through instances and run the command in the background
for i in "${!instances[@]}"; do
    instance="${instances[$i]}"
    region="${regions[$i]}"
    
    # Run the SSH command in the background and store the process ID
    gcloud compute ssh "$instance" --zone "$region" --command "$command" &
    pids+=($!)
done

# Wait for all background processes to complete
for pid in "${pids[@]}"; do
    wait $pid
done
