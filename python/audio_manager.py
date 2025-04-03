import sounddevice as sd
from pitch_detect import PitchDetector
from clap_snap_detect import ClapSnapDetector
from util import debug
from signal import SignalType

class AudioManager:
    def __init__(self, signal_callback):
        self.samplerate = 44100  # Hz
        self.block_size = 8192  # Samples per block

        self.pitch_detector = PitchDetector(self.samplerate)
        self.clap_snap_detector = ClapSnapDetector(self.samplerate)

        self.signal_callback = signal_callback
    
    def _audio_callback(self, indata, frames, time, status):
        """
        This callback receives each audio block and passes to PitchDetector and ClapSnapDetector for processing
        """
        if status:
            debug("Stream status: "+status)

        # Assume mono input; if stereo, pick one channel.
        samples = indata[:, 0]

        # Compute the pitch & clap/snap signals for the current block.
        pitch_signal = self.pitch_detector.detect(samples)
        clap_snap_signal = self.clap_snap_detector.detect(samples)

        # Send to client callback
        if (clap_snap_signal['type'] != SignalType.NO_CLAP_SNAP):
            self.signal_callback(clap_snap_signal)
        else:
            self.signal_callback(pitch_signal)
        
    
    def start(self):
        with sd.InputStream(channels=1, samplerate=self.samplerate, blocksize=self.block_size,
                            dtype='float32', callback=self._audio_callback):
            debug(f"Started listening... Press ENTER to stop.")
            input()
