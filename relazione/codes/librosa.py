# parameters
self.sr_downs = 22050
self.hop_length = 512
self.n_bins = 192
self.bins_per_octave = 24
        
self.frameDuration = self.hop_length / self.sr_downs
        
# save file path
self.save_path = self.path_data + "dataset1/"

def audio_CQT(self, file_num, start, dur):  # start and dur in seconds
    path = os.path.join(self.path_audio, 
                        os.listdir(self.path_audio)[file_num])
        
    # Function for removing noise
    def cqt_lim(CQT):
        new_CQT = np.copy(CQT)
        new_CQT[new_CQT < -60] = -120
        return new_CQT

    # Perform the Constant-Q Transform
    data, sr = librosa.load(path, sr = self.sr_downs, 
                            mono = True, offset = start, duration = dur)
    data = librosa.util.normalize(data)
    data = librosa.cqt(data, sr = self.sr_downs, 
                        hop_length = self.hop_length, 
                        fmin = None, 
                        n_bins = self.n_bins, 
                        bins_per_octave = self.bins_per_octave)
    data = librosa.magphase(data)[0]**4
    data = librosa.core.amplitude_to_db(data, ref = np.amax)
    cqt = cqt_lim(data)
    return cqt