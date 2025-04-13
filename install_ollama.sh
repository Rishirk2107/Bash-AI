echo "🔍 Checking if Ollama is already installed..."
if command -v ollama &> /dev/null
then
    echo "✅ Ollama is already installed. Skipping installation."
else
    echo "⬇️ Installing required dependency (curl)..."
    sudo apt update
    sudo apt install -y curl

    echo "📦 Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh

    if ! command -v ollama &> /dev/null
    then
        echo "❌ Ollama installation failed. Please troubleshoot manually."
        exit 1
    fi
fi

echo "🚀 Starting the model in background: dagbs/qwen2.5-coder-0.5b-instruct-abliterated"
nohup ollama run dagbs/qwen2.5-coder-0.5b-instruct-abliterated > ollama_output.log 2>&1 &

echo "⌛ Waiting 5 seconds for Ollama to warm up..."
sleep 5

echo "📦 Ensuring 'requests' library is installed for Python..."
pip install requests --quiet

echo "🧠 Launching Linux Assistant Python App..."
python3 main.py
