#!/bin/bash

# Display intro named bashAI in ASCII Art style
echo "🧠"
echo " ____            _        _    ___ "
echo "| __ )  __ _ ___| |__    / \  |_ _|"
echo "|  _ \ / _\` / __| '_ \  / _ \  | | "
echo "| |_) | (_| \__ \ | | |/ ___ \ | | "
echo "|____/ \__,_|___/_| |_/_/   \_\___|"
echo ""
echo ""

# 🧐 Check if running inside systemd-nspawn container
if [ -f /etc/machine-id ]; then
    echo "🔐 Running inside systemd-nspawn container. Adjusting environment."
    CONTAINER=true
else
    echo "🚀 Running on the host system. Proceeding with normal execution."
    CONTAINER=false
fi

# Check if Ollama is already installed
if command -v ollama &> /dev/null
then
    echo "Ollama is already installed. Skipping installation."
else
    echo "⬇Ollama is not installed. Would you like to install it? (y/n)"
    read -r INSTALL_RESPONSE

    if [[ "$INSTALL_RESPONSE" == "y" || "$INSTALL_RESPONSE" == "Y" ]]; then
        echo "Installing Ollama..."

        # Install dependencies and Ollama
        if [ "$CONTAINER" = true ]; then
            apt update && apt install -y curl
        else
            sudo apt update && sudo apt install -y curl
        fi

        curl -fsSL https://ollama.com/install.sh | sh

        if ! command -v ollama &> /dev/null
        then
            echo "Ollama installation failed. Please troubleshoot manually."
            exit 1
        fi
    else
        echo "Ollama installation skipped. Exiting..."
        exit 0
    fi
fi

# 🧠 Detect best model based on RAM
if [ ! -f .model_name ]; then
    chmod +x detect_model.sh
    ./detect_model.sh
    if [ $? -ne 0 ]; then
        echo "Model selection failed due to insufficient RAM."
        exit 1
    fi

    MODEL_NAME=$(cat .model_name)
    echo "Model selected based on RAM: $MODEL_NAME"
else
    echo "Model already selected based on previous detection."
    MODEL_NAME=$(cat .model_name)
fi

# Pull model and show the installation output
echo "📦 Pulling model: $MODEL_NAME ..."
ollama pull "$MODEL_NAME"

if [ $? -ne 0 ]; then
    echo "Failed to pull model: $MODEL_NAME"
    exit 1
fi

echo "Starting the model in background: $MODEL_NAME"
nohup ollama run "$MODEL_NAME" > ollama_output.log 2>&1 &

echo "⌛ Waiting 5 seconds for Ollama to warm up..."
sleep 5

# Ensure 'requests' library is installed for Python
if [ "$CONTAINER" = true ]; then
    pip install requests --quiet
else
    sudo pip install requests --quiet
fi

# Launch Linux Assistant Python App
python3 main.py
