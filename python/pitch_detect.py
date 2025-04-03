from signal import SignalType

class PitchDetector():
    def __init__(self, samplerate):
        self.samplerate = samplerate

    def detect(self, samples):
        return {'type':SignalType.PITCH_NONE}
