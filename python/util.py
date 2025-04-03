import sys

def debug(str):
    sys.stderr.write(f"{str}\n")
    sys.stderr.flush()

def send_to_godot(str):
    sys.stdout.write(f"{str}\n")
    sys.stdout.flush()
