import requests
import subprocess
import re

OLLAMA_URL = "http://localhost:11434/api/generate"

with open(".model_name", "r") as f:
    MODEL_NAME = f.read().strip()

def ask_linux_question(question):
    prompt = f"""You are a Linux expert. Answer the following question clearly and concisely, and provide the perfect bash command for the answer:\n\n{question}"""

    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False
    }

    response = requests.post(OLLAMA_URL, json=payload)
    if response.ok:
        return response.json()["response"].strip()
    else:
        return f"Error: {response.text}"

def extract_command(response):
    match = re.search(r"```bash\s+(.+?)\s+```", response, re.DOTALL)
    return match.group(1).strip() if match else None

def execute_command(command):
    try:
        output = subprocess.check_output(command + " 2>/dev/null", shell=True, stderr=subprocess.STDOUT, text=True)
        print("🖥️ Command Output:\n" + output)
    except subprocess.CalledProcessError as e:
        print("⚠️ Error while executing the command:\n" + e.output)

if __name__ == "__main__":
    print("👨‍💻 Ask anything about Linux commands (type 'exit' to quit):")
    while True:
        user_input = input("🧠 You: ")
        if user_input.lower() in ("exit", "quit"):
            break

        response = ask_linux_question(user_input)
        print(f"\n🤖 Ollama:\n{response}\n")

        command = extract_command(response)
        if command:
            confirm = input(f"⚙️ Detected command:\n`{command}`\n👉 Execute this command? (yes/no): ").strip().lower()
            if confirm in ("y", "yes"):
                execute_command(command)
            else:
                print("❌ Skipped command execution.\n")
