import numpy as np
import matplotlib.pyplot as plt
import librosa
import os
import math
from tensorflow.keras.utils import normalize
from scipy.io import wavfile


# parameters
sr_downs = 22050
hop_length = 512
n_bins = 192
bins_per_octave = 24

def audio_CQT(path):   
    # Perform the Constant-Q Transform
    data, sr = librosa.load(path, sr = sr_downs, mono = True)
    data = librosa.util.normalize(data)
    data = librosa.cqt(data, sr = sr_downs, hop_length = hop_length, fmin = None, n_bins = n_bins, bins_per_octave = bins_per_octave)
    CQT = np.abs(data)
    return CQT

def preprocessing_file(path):
    images = []

    cqt = np.swapaxes(audio_CQT(path), 0, 1)
    full_x = np.pad(cqt, [(4,4), (0,0)], mode='constant')

    for n in range(len(cqt)):
        sample_x = np.swapaxes(full_x[n : n + 9], 0, 1)
        images.append(sample_x.astype('float32'))

    images = np.expand_dims(np.array(images), axis=-1)
    return images