import pyautogui
import time
import random

hacker_msgs = [
    "⚠️ Access Granted: Root Level",
    "💻 Injecting payload...",
    "🛡️ Bypassing firewall rules...",
    "🔓 Cracking credentials...",
    "📡 Connecting to C2 server...",
    "📁 Downloading confidential files...",
    "🧠 AI core compromised.",
    "⏳ Waiting for zero-day trigger...",
    "🔐 AES-256 encryption breached.",
    "🧬 DNA scan verified. Identity matched.",
    "📶 Signal traced to unknown source.",
    "📤 Uploading reverse shell...",
    "💥 Virus initiated: smile.exe",
    "🦠 Deploying worm to network...",
    "📲 Hijacking SMS gateway...",
    "🚨 ALERT: FBI tracing attempt blocked.",
    "🔁 Loop injection successful.",
    "📂 Rootkit embedded in kernel.",
    "⚙️ System DLL override complete.",
    "🎯 Target locked.",
    "☠️ Remote brainwave sync initialized.",
    "🌐 Tor node compromised.",
    "🎭 Identity spoofed: Anonymous mode ON.",
    "🌀 Matrix sync complete.",
    "🧊 Freezing RAM to dump content...",
    "🔍 Stealing browser passwords...",
    "📦 Installing keylogger...",
    "🗝️ Master password found.",
    "⚠️ Enabling Quantum backdoor...",
    "🕳️ Hole punched through NAT firewall.",
    "📡 WiFi router firmware replaced.",
    "🚫 Antivirus disabled.",
    "🖥️ Screen mirroring initiated.",
    "🕵️‍♂️ Webcam is now streaming...",
    "🧱 Encrypting system32...",
    "💿 Burning backup disks...",
    "🚀 Launching botnet attack...",
    "🪙 Mining crypto using your GPU...",
    "🧬 DNA mutated. Just kidding. Or not.",
    "💡 LED flicker pattern updated.",
    "🌌 Connecting to alien server...",
    "💤 Putting system into sleep-mode trap...",
    "🔄 Overclocking CPU to 9999%",
    "📲 Sending SMS to all contacts...",
    "💥 Boom.exe activated!",
    "🛑 System locked by Black Hat Syndicate.",
    "📛 BIOS rewrite in progress...",
    "🌈 Injecting colorful chaos...",
    "🥷 Ninja script deployed silently.",
    "💣 Self-destruct countdown: 3... 2... 1..."
]

# زنجیره‌ی popupها:
for i in range(50):
    msg = hacker_msgs[i % len(hacker_msgs)]
    pyautogui.alert(msg, title=f"🔒 Hack Alert [{i+1}/50]")
    time.sleep(0.5)
