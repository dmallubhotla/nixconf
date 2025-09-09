#!/usr/bin/env bash
# Notify with tmux?

message="
$1

exit with ctrl-C, resume next with uairctl
"

echo "sth"
echo "$message"

tmux display-popup -T "uair" "echo -e \"$message\""

