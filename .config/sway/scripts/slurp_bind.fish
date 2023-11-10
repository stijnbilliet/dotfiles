#!/usr/bin/env fish

# Create a named pipe
set slurpie (mktemp -u)
mkfifo $slurpie

# Start slurp in the background and redirect its output to the named pipe
begin; slurp > $slurpie; end &

# Get the PID of the background process
set pid $last_pid

# Wait for 100 microseconds
sleep 0.1

# Simulate mouse click
swaymsg seat - cursor press button1

# Wait for the background process to finish
wait $pid

# Pass the output of slurp (from the named pipe) to grim
cat $slurpie

# Remove the named pipe
rm $slurpie