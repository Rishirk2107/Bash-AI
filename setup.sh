echo "🧠"
echo " ____            _        _    ___ "
echo "| __ )  __ _ ___| |__    / \  |_ _|"
echo "|  _ \ / _\` / __| '_ \  / _ \  | | "
echo "| |_) | (_| \__ \ | | |/ ___ \ | | "
echo "|____/ \__,_|___/_| |_/_/   \_\___|"
echo ""
echo ""

echo "Checking if Ollama is already installed..."
if command -v ollama &> /dev/null
then
    echo "Ollama is already installed. Skipping installation."
else
    echo "Installing required dependency (curl)..."
    sudo apt update
    sudo apt install -y curl

    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh

    if ! command -v ollama &> /dev/null
    then
        echo "Ollama installation failed. Please troubleshoot manually."
        exit 1
    fi
fi

# Detect best model based on RAM
chmod +x detect_model.sh
./detect_model.sh
if [ $? -ne 0 ]; then
    echo "Model selection failed due to insufficient RAM."
    exit 1
fi

MODEL_NAME=$(cat .model_name)

echo " Model selected based on RAM: $MODEL_NAME"

echo "Pulling model: $MODEL_NAME ..."
ollama pull "$MODEL_NAME"

if [ $? -ne 0 ]; then
    echo "Failed to pull model: $MODEL_NAME"
    exit 1
fi

echo "Starting the model in background: $MODEL_NAME"
nohup ollama run "$MODEL_NAME" > ollama_output.log 2>&1 &

echo "Waiting 5 seconds for Ollama to warm up..."
sleep 5

echo "Ensuring 'requests' library is installed for Python..."
pip install requests --quiet

echo "Launching Linux Assistant Python App..."
python3 main.py
