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

frameDuration = hop_length / sr_downs


def audio_CQT(path, start, dur):  # start and dur in seconds      
    # Function for removing noise
    def cqt_lim(CQT):
        new_CQT = np.copy(CQT)
        new_CQT[new_CQT < -60] = -120
        return new_CQT

    # Perform the Constant-Q Transform
    data, sr = librosa.load(path, sr = sr_downs, mono = True, offset = start, duration = dur)
    data = librosa.util.normalize(data)
    CQT = librosa.cqt(data, sr = sr_downs, hop_length = hop_length, fmin = None, n_bins = n_bins, bins_per_octave = bins_per_octave)
    CQT_mag = librosa.magphase(CQT)[0]**4
    CQTdB = librosa.core.amplitude_to_db(CQT_mag, ref = np.amax)
    new_CQT = cqt_lim(CQTdB)
    return new_CQT

def get_duration_seconds(path):
    file_audio = path
    (source_rate, source_sig) = wavfile.read(file_audio)
    duration_seconds = len(source_sig) / float(source_rate)
    return duration_seconds

def scal_norm_exp(img):
    arr = []

    a = img
    a_min = np.min(a)
    a_max = np.max(a)
    a_scaled = 255*(a-a_min)/(a_max-a_min)

    imgnorm = a_scaled
    imgnorm = normalize(imgnorm, axis=2)

    for n in range(len(imgnorm)):
        arr.append(imgnorm[n])

    images = np.expand_dims(np.array(arr), axis=-1)
    return images

def preprocessing_file(path):
    img = []
    times = np.arange(0.0, get_duration_seconds(path), 0.2)

    for t in range(len(times)-1):
        cqt = audio_CQT(path, times[t], times[t+1]-times[t])
        img.append(cqt)

    images = scal_norm_exp(img)

    return images