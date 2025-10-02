#!/bin/bash

# Get all sink names in a list
sinks=($(pactl list short sinks | awk '{print $2}' | grep -v "alsa_output.platform-snd_aloop.0.analog-stereo"))


# Get current default sink
current=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Find index of current sink in list
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current" ]]; then
        index=$i
        break
    fi
done

# Pick the next sink (wrap around with modulo)
next_index=$(( (index + 1) % ${#sinks[@]} ))
next_sink=${sinks[$next_index]}

# Set it as default
pactl set-default-sink "$next_sink"

# Move all current audio streams to new sink
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$next_sink"
done

notify-send "Audio Output Switched" "Now using: $next_sink"
