import datetime
import random
import os
import time
import threading
import webbrowser
import pyautogui
import ctypes
import winsound

# === 1. Birthday Detection ===
def is_birthday():
    today = datetime.datetime.now()
    return today.day == 5 and today.month == 4  # 🎂 Replace with real birthday

# === 2. Rickroll and popup madness ===
def open_fun_stuff():
    links = [
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",  # Rickroll
        "https://pointerpointer.com/",
        "https://heeeeeeeey.com/",
        "https://cat-bounce.com/",
    ]
    for link in links:
        webbrowser.open(link)
        time.sleep(3)

def play_sound():
    duration = 400  # milliseconds
    freq = 600  # Hz
    for i in range(10):
        winsound.Beep(freq + random.randint(0, 300), duration)

def popup_chain():
    messages = [
        "🔔 System Alert: Birthday Mode Enabled.",
        "💣 WARNING: Smile Detected!",
        "🎉 Surprise! You’re the star today!",
        "🛠️ Error 404: Seriousness Not Found.",
        "🧁 Initiating cake.exe...",
    ]
    for msg in messages:
        pyautogui.alert(msg, "System Notification")
        time.sleep(1)

def move_mouse():
    for _ in range(50):
        x, y = pyautogui.position()
        pyautogui.moveTo(x + random.randint(-10, 10), y + random.randint(-10, 10))
        time.sleep(0.1)

# === 3. Run All Together ===
def birthday_party():
    threading.Thread(target=popup_chain).start()
    threading.Thread(target=play_sound).start()
    threading.Thread(target=open_fun_stuff).start()
    threading.Thread(target=move_mouse).start()

# === 4. Main ===
def main():
    if is_birthday():
        birthday_party()

# === 5. Start silently ===
if __name__ == "__main__":
    threading.Thread(target=main).start()
