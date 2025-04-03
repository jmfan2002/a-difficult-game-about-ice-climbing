import numpy as np
from signal import SignalType

class PitchDetector():
    def __init__(self, samplerate):
        self.samplerate = samplerate

        # Typical frequency range for human voice
        self.min_freq = 50   # Hz
        self.max_freq = 2000 # Hz

        self.energy_threshold = 0.02  # to set a minimum energy level for pitches

        # To store pitch of previous blocks to decide if pitch is going up or down
        self.pitch_history = []
        self.history_length = 5  # number of previous blocks

    def _detect_pitch_autocorr(self, samples):
        """
        Detects pitch from a given audio signal using autocorrelation.
        
        Parameters:
        samples (np.array): The input audio block (1D numpy array).
        
        Returns:
        float: Detected pitch in Hz (or 0 if not found).
        """
        # Apply a Hanning window to reduce spectral leakage.
        window = np.hanning(len(samples))
        samples = samples * window

        # Compute the autocorrelation of the windowed signal.
        corr = np.correlate(samples, samples, mode='full')
        corr = corr[len(corr)//2:]  # Take only the second half

        min_lag = int(self.samplerate / self.max_freq)
        max_lag = int(self.samplerate / self.min_freq)

        # Only consider lags within our expected pitch range.
        if max_lag > len(corr):
            max_lag = len(corr)
        corr_segment = corr[min_lag:max_lag]
        if len(corr_segment) == 0:
            return 0

        # Find the lag with the maximum autocorrelation value.
        peak_index = np.argmax(corr_segment)
        lag = peak_index + min_lag
        if lag == 0:
            return 0

        # Calculate the pitch from the lag.
        pitch = self.samplerate / lag
        return pitch

    def _detect_pitch_fft(self, samples):
        """
        Detects pitch from a given audio signal using FFT.

        Parameters:
        samples (np.array): The input audio block (1D numpy array).

        Returns:
        float: Detected pitch in Hz (or 0 if not found).
        """
        # Apply a Hanning window to reduce spectral leakage.
        window = np.hanning(len(samples))
        samples = samples * window

        # Compute FFT and get the magnitude spectrum.
        fft_spectrum = np.fft.rfft(samples)  # Real FFT (faster for real signals)
        magnitudes = np.abs(fft_spectrum)   # Get magnitude of frequencies

        # Get the frequency values corresponding to FFT bins.
        freqs = np.fft.rfftfreq(len(samples), d=1/self.samplerate)

        # Filter indices that correspond to valid frequencies.
        valid_indices = np.where((freqs >= self.min_freq) & (freqs <= self.max_freq))[0]

        if len(valid_indices) == 0:
            return 0  # No valid frequencies detected

        # Find the peak frequency.
        peak_index = valid_indices[np.argmax(magnitudes[valid_indices])]
        pitch = freqs[peak_index]
        return pitch

    def detect(self, samples):
        # compute pitch
        pitch = self._detect_pitch_autocorr(samples)
        self.pitch_history.append(pitch)
        if len(self.pitch_history) > self.history_length:
            self.pitch_history.pop(0)

        # ignore if this is the very first block
        if (len(self.pitch_history) < 2):
            signal = SignalType.PITCH_NONE
        elif self.pitch_history[-1] > self.pitch_history[-2]:
            signal = SignalType.PITCH_UP
        else:
            signal = SignalType.PITCH_DOWN
        return {'type':signal, 'pitch':pitch}
