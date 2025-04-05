import sys
from audio_manager import AudioManager
from signal import SignalType
from util import debug, send_to_godot

class GodotClient():
	def __init__(self):
		# Audio Manager
		device_idx = int(sys.argv[1])
		self.audio_manager = AudioManager(self.signal_callback, device_idx)
	
	def start(self):
		self.audio_manager.start()
	
	def signal_callback(self, signals):
		for signal in signals:
			if (signal['type'] in [SignalType.CLAP, SignalType.SNAP]):
				debug("sending clap/snap")
			match signal['type']:
				case SignalType.NO_CLAP_SNAP:
					continue
				case _:
					send_to_godot(signal['type'].value)

if __name__ == "__main__":
	debug(f"GODOT client starting, connected to device...")
	client = GodotClient()
	client.start()
