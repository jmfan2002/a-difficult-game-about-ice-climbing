import socket
import sys
from audio_manager import AudioManager
from signal import SignalType
from util import debug

class UdpClient():
	def __init__(self):
		## UDP connection
		self.ip = "127.0.0.1"
		self.port = int(sys.argv[1])
		self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.client_socket.settimeout(5)

		# Audio Manager
		device_idx = int(sys.argv[2])
		self.audio_manager = AudioManager(self.signal_callback, device_idx)
		print(f"Connected to device {device_idx}")
	
	def start(self):
		self.audio_manager.start()
	
	def signal_callback(self, signal):
		match signal['type']:
			case SignalType.NO_CLAP_SNAP:
				pass
			case _:
				self.client_socket.sendto(signal['type'].value.encode(), (self.ip, self.port))

if __name__ == "__main__":
	debug(f"UDP client starting, connected to device...")
	client = UdpClient()
	client.start()
