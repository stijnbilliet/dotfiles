#!/usr/bin/fish

# Named pipe using random path
set pipe_name (mktemp -u)
mkfifo "$pipe_name"
# Start slurp in the background and redirect its output to the named pipe
begin; slurp > pipe_name&; end
sleep 0.05
swaymsg seat - cursor press button1
wait
cat pipe_name
rm pipe_name
