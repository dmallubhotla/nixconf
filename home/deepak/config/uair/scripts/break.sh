#!/usr/bin/env bash
# Notify with tmux?

message="Break done"

echo "sth"
echo "$message"

tmux display-popup -T "uair" "echo -e \"$message\""

