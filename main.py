#import tensorflow as tf
#from tensorflow import keras
import matplotlib.pyplot as plt
from audioCQT import audio_CQT

new_CQT = audio_CQT(13,0,1)

plt.xlabel('Time')
plt.ylabel('Note')
plt.imshow(new_CQT, interpolation='nearest', aspect='auto', extent=[0, 1, 1, 9])
plt.savefig("img.png")


