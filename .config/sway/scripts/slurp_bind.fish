#!/usr/bin/fish

# Create a named pipe
set pipe_name (mktemp -u)
mkfifo "$pipe_name"

# Start slurp in the background and redirect its output to the named pipe
begin; slurp > pipe_name&; end

# Wait for 200 microseconds
sleep 0.1

# Simulate mouse click
swaymsg seat - cursor press button1

# Wait for the background process to finish
wait

# Read out pipe/file
cat pipe_name

# Remove the named pipe
rm pipe_name
