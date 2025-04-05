import numpy as np
from signal import SignalType

class ClapSnapDetector():
    def __init__(self, samplerate):
        self.samplerate = samplerate

        # Detection thresholds (tune these based on your environment)
        self.energy_threshold = 0.01             # Minimum RMS energy to consider an event
        
        self.spectral_centroid_threshold = 2800  # Frequency (Hz) threshold to distinguish snap vs. clap
        # seems like setting this to 0 allows for clapping while still singing
        self.transient_factor = 0.0              # Require the block energy to be at least 2x the recent average
        self.voice_threshold = 1600              # Frequency (Hz) threshold to filter out vocal transients

        # To store energy of previous blocks to help decide if an event is transient
        self.energy_history = []
        self.history_length = 5  # number of previous blocks to average
    
    def compute_rms(self, samples):
        """Compute the root mean square energy of the signal."""
        return np.sqrt(np.mean(samples**2))

    def compute_spectral_centroid(self, samples):
        """
        Compute the spectral centroid of a signal.
        The spectral centroid indicates the "brightness" of a sound.
        """
        # Apply a Hanning window to reduce spectral leakage.
        window = np.hanning(len(samples))
        windowed_samples = samples * window

        # Compute the FFT magnitude spectrum
        fft_vals = np.abs(np.fft.rfft(windowed_samples))
        # Frequency bins corresponding to the FFT
        freqs = np.fft.rfftfreq(len(samples), d=1.0/self.samplerate)
        if np.sum(fft_vals) == 0:
            return 0
        centroid = np.sum(freqs * fft_vals) / np.sum(fft_vals)
        return centroid

    def detect(self, samples):
        # Compute the RMS energy of the current block
        rms = self.compute_rms(samples)
        
        # Update the energy history and compute a moving average
        self.energy_history.append(rms)
        if len(self.energy_history) > self.history_length:
            self.energy_history.pop(0)
        avg_energy = np.mean(self.energy_history) if self.energy_history else self.energy_threshold

        # Only consider this block if it's a sudden (transient) spike in energy.
        # This helps avoid detecting continuous sounds (like speech).
        if rms > self.energy_threshold and rms > self.transient_factor * avg_energy:
            centroid = self.compute_spectral_centroid(samples)
            
            # Decide if the event is a snap (higher spectral centroid) or a clap.
            if centroid < self.voice_threshold:
                return {'type':SignalType.NO_CLAP_SNAP}
            elif centroid > self.spectral_centroid_threshold:
                return {'type':SignalType.SNAP, 'rms':rms, 'centroid':centroid}
            else:
                return {'type':SignalType.CLAP, 'rms':rms, 'centroid':centroid}
        # Otherwise, ignore the event (likely part of continuous speech)
        else:
            return {'type':SignalType.NO_CLAP_SNAP}
