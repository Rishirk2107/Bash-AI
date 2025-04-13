#!/bin/bash

# detect_model.sh

echo "🧠 Checking system RAM..."
total_kb=$(grep MemTotal /proc/meminfo | awk '{ print $2 }')
total_gb=$(echo "scale=2; $total_kb / 1024 / 1024" | bc)
echo "💾 Total RAM Detected: $total_gb GB"

# 🌟 Model Selection Logic
if (( $(echo "$total_gb > 14" | bc -l) )); then
    MODEL_NAME="qwen2.5-coder:3b"
elif (( $(echo "$total_gb > 7" | bc -l) )); then
    MODEL_NAME="qwen2.5-coder:1.5b"
elif (( $(echo "$total_gb > 3" | bc -l) )); then
    MODEL_NAME="qwen2.5-coder:0.5b"
else
    echo "❌ Not enough RAM to run the model. Minimum 4 GB required."
    exit 1
fi

echo "🤖 Selected Model: $MODEL_NAME"
echo "$MODEL_NAME" > .model_name
