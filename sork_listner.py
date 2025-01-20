import socket

def start_listener(host, port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
            server_socket.bind((host, port))
            server_socket.listen(5)
            print(f"Listening on {host}:{port}...")
            while True:
                client_socket, client_address = server_socket.accept()
                print(f"Connection from {client_address}")
                data = client_socket.recv(4096).decode('utf-8')
                print("Received data:")
                print(data)
                with open("received_profiles.txt", "a") as file:
                    file.write(data)
                client_socket.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    start_listener("0.0.0.0", 4444)
