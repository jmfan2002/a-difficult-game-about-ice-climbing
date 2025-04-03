from enum import Enum

class SignalType(Enum):
    PITCH_UP = 'PITCH_UP'
    PITCH_DOWN = 'PITCH_DOWN'
    PITCH_NONE = 'PITCH_NONE'
    CLAP = 'CLAP'
    SNAP = 'SNAP'
    NO_CLAP_SNAP = 'NO_CLAP_SNAP'
