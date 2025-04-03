from audio_manager import AudioManager
from signal import SignalType

class CliClient():
    def __init__(self):
        # Audio Manager
        self.audio_manager = AudioManager(self.signal_callback)
    
    def start(self):
        self.audio_manager.start()
    
    def signal_callback(self, signal):
        match signal['type']:
            case SignalType.PITCH_UP | SignalType.PITCH_DOWN:
                print(f"\rSignal: {signal['type'].value}, Energy: {signal['rms']:.3f} Pitch: {signal['pitch']:.2f} Hz     ", end="", flush=True)
            case SignalType.PITCH_NONE:
                print(f"\rSignal: {signal['type'].value}, Pitch: -1 Hz     ", end="", flush=True)
            case SignalType.CLAP | SignalType.SNAP:
                print(f"\rDetected {signal['type'].value}! RMS: {signal['rms']:.4f}, Centroid: {signal['centroid']:.2f} Hz")

if __name__ == "__main__":
    print("CLI client starting...")
    client = CliClient()
    client.start()
