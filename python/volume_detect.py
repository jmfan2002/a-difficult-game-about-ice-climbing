import numpy as np
from signal import SignalType

class VolumeDetector():
    def __init__(self):
        self.energy_threshold = 0.02  # to set a minimum energy level for pitches

        # To store pitch of previous blocks to decide if volume is going up or down
        self.vol_history = []
        self.history_length = 5  # number of previous blocks

    def compute_rms(self, samples):
        """Compute the root mean square energy of the signal."""
        return np.sqrt(np.mean(samples**2))

    def detect(self, samples):
        # compute rms
        rms = self.compute_rms(samples)
        self.vol_history.append(rms)
        if len(self.vol_history) > self.history_length:
            self.vol_history.pop(0)

        # check if min energy is hit (ie. someone is singing)
        if (rms < self.energy_threshold):
            signal = SignalType.VOL_NONE
        # ignore if this is the very first block
        elif (len(self.vol_history) < 2):
            signal = SignalType.VOL_NONE
        elif self.vol_history[-1] > self.vol_history[-2]:
            signal = SignalType.VOL_UP
        else:
            signal = SignalType.VOL_DOWN
        return {'type':signal, 'rms':rms}
