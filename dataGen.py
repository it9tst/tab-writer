import os
import jams
import numpy as np
import librosa
import math
import datetime
from scipy.io import wavfile

class dataGen:
    
    def __init__(self, path):
        # file path to the GuitarSet dataset
        self.path_data = path
        self.path_audio = self.path_data + "GuitarSet/audio_mono-mic/"
        self.path_anno = self.path_data + "GuitarSet/annotation/"
              
        # array and dict
        self.labels = []
        self.img = []
        self.output = {}

        # parameters
        self.sr_downs = 22050
        self.hop_length = 1024
        self.n_bins = 96
        self.bins_per_octave = 12
        
        self.frameDuration = self.hop_length / self.sr_downs
        
        # save file path
        self.save_path = self.path_data + "train/"

    def audio_CQT(self, file_num, start, dur):  # start and dur in seconds
        path = os.path.join(self.path_audio, os.listdir(self.path_audio)[file_num])
        
        # Function for removing noise
        def cqt_lim(CQT):
            new_CQT = np.copy(CQT)
            new_CQT[new_CQT < -60] = -120
            return new_CQT

        # Perform the Constant-Q Transform
        data, sr = librosa.load(path, sr = None, mono = True, offset = start, duration = dur)
        CQT = librosa.cqt(data, sr = self.sr_downs, hop_length = self.hop_length, fmin = None, n_bins = self.n_bins, bins_per_octave = self.bins_per_octave)
        CQT_mag = librosa.magphase(CQT)[0]**4
        CQTdB = librosa.core.amplitude_to_db(CQT_mag, ref = np.amax)
        new_CQT = cqt_lim(CQTdB)

        return new_CQT

    def spacejam(self, file_num, start, stop): # start and stop in seconds
        path = os.path.join(self.path_anno, os.listdir(self.path_anno)[file_num])
        jam = jams.load(path)

        # Initialize variables
        cnt_row = -1
        cnt_col = 0
        cnt_zero = 0

        # Grab all relevant MIDI data (available in MIDI_dat)
        for i in range(0, len(jam['annotations'])):
            if jam['annotations'][int(i)]['namespace'] == 'note_midi':
                for j in range(0, len(sorted(jam['annotations'][int(i)]['data']))):
                    cnt_row = cnt_row + 1
                    for k in range(0, len(sorted(jam['annotations'][int(i)]['data'])[int(j)]) - 1):
                        if cnt_zero == 0:
                            MIDI_arr = np.zeros((len(sorted(jam['annotations'][int(i)]['data'])), len(sorted(jam['annotations'][int(i)]['data'])[int(j)]) - 1), dtype = np.float32)
                            cnt_zero = cnt_zero + 1
                        if cnt_zero > 0:
                            MIDI_arr = np.vstack((MIDI_arr, np.zeros((len(sorted(jam['annotations'][int(i)]['data'])), len(sorted(jam['annotations'][int(i)]['data'])[int(j)]) - 1), dtype = np.float32)))
                            cnt_zero = cnt_zero + 1  # Keep
                        if cnt_col > 2:
                            cnt_col = 0
                        MIDI_arr[cnt_row, cnt_col] = sorted(jam['annotations'][int(i)]['data'])[int(j)][int(k)]
                        cnt_col = cnt_col + 1
        MIDI_dat = np.zeros((cnt_row + 1, cnt_col), dtype = np.float32)
        cnt_col2 = 0
        for n in range(0, cnt_row + 1):
            for m in range(0, cnt_col):
                if cnt_col2 > 2:
                    cnt_col2 = 0
                MIDI_dat[n, cnt_col2] = MIDI_arr[n, cnt_col2]
                cnt_col2 = cnt_col2 + 1

        # Return the unique MIDI notes played (available in MIDI_val)
        MIDI_dat_dur = np.copy(MIDI_dat)
        for r in range(0, len(MIDI_dat[:, 0])):
            MIDI_dat_dur[r, 0] = MIDI_dat[r, 0] + MIDI_dat[r, 1]
        tab_1, = np.where(np.logical_and(MIDI_dat[:, 0] >= start, MIDI_dat[:, 0] <= stop))
        tab_2, = np.where(np.logical_and(MIDI_dat_dur[:, 0] >= start, MIDI_dat_dur[:, 0] <= stop))
        tab_3, = np.where(np.logical_and(np.logical_and(MIDI_dat[:, 0] < start, MIDI_dat_dur[:, 0] > stop), MIDI_dat[:, 1] > int(stop-start)))
        if tab_1.size != 0 and tab_2.size == 0 and tab_3.size == 0:
            tab_ind = tab_1
        if tab_1.size == 0 and tab_2.size != 0 and tab_3.size == 0:
            tab_ind = tab_2
        if tab_1.size == 0 and tab_2.size == 0 and tab_3.size != 0:
                tab_ind = tab_3
        if tab_1.size != 0 and tab_2.size != 0 and tab_3.size == 0:
            tab_ind = np.concatenate([tab_1, tab_2])
        if tab_1.size != 0 and tab_2.size == 0 and tab_3.size != 0:
            tab_ind = np.concatenate([tab_1, tab_3])
        if tab_1.size == 0 and tab_2.size != 0 and tab_3.size != 0:
            tab_ind = np.concatenate([tab_2, tab_3])
        if tab_1.size != 0 and tab_2.size != 0 and tab_3.size != 0:
            tab_ind = np.concatenate([tab_1, tab_2, tab_3])
        if tab_1.size == 0 and tab_2.size == 0 and tab_3.size == 0:
            tab_ind = []
        if len(tab_ind) != 0:
            MIDI_val = np.zeros((len(tab_ind), 1), dtype = np.float32)
            for z in range(0, len(tab_ind)):
                MIDI_val[z, 0] = int(round(MIDI_dat[tab_ind[z], 2]))
        elif len(tab_ind) == 0:
            MIDI_val = []
        MIDI_val = np.unique(MIDI_val)
        if MIDI_val.size >= 6:
            MIDI_val = np.delete(MIDI_val, np.s_[6::])

        if len(MIDI_val) > 0:
            # Initialize variables
            f_row = np.full((6, 6), np.inf)  # 6 strings with 1 note per string
            f_col = np.full((6, 6), np.inf)

            # Initialize variables
            Fret = np.zeros((6, 18), dtype = np.int32)
            Sol = np.copy(Fret)
            fcnt = -1
            fcnt2 = 0

            # Retrieve all possible notes played
            for q in range(0, 6):
                for e in range(0, 18):
                    if q == 0:
                        Fret[q, e] = 40 + e
                    elif q == 1:
                        Fret[q, e] = 45 + e
                    elif q == 2:
                        Fret[q, e] = 50 + e
                    elif q == 3:
                        Fret[q, e] = 55 + e
                    elif q == 4:
                        Fret[q, e] = 59 + e
                    elif q == 5:
                        Fret[q, e] = 64 + e

            for t in range(0, len(MIDI_val)):
                Fret_played = (Fret == int(MIDI_val[t]))
                fcnt = fcnt + 1
                cng = 0
                for dr in range(0, len(Fret[:, 0])):
                    for dc in range(0, len(Fret[0, :])):
                        if Fret_played[dr, dc]*1 == 1:
                            if cng == 0:
                                fcnt2 = 0
                                cng = cng + 1
                            f_row[fcnt, fcnt2] = dr
                            f_col[fcnt, fcnt2] = dc
                            fcnt2 = fcnt2 + 1
                        Fret_played[dr, dc] = Fret_played[dr, dc]*1
                        if Fret_played[dr, dc] == 1:
                            Sol[dr, dc] = Fret_played[dr, dc]

            # Initialize the 6 possible note solutions (one note per string)
            f_sol_0 = np.copy(f_col)
            f_sol_1 = np.copy(f_col)
            f_sol_2 = np.copy(f_col)
            f_sol_3 = np.copy(f_col)
            f_sol_4 = np.copy(f_col)
            f_sol_5 = np.copy(f_col)
            pri_cnt_c, = np.where(np.isfinite(f_col[0, :]))
            pri_cnt_r, = np.where(np.isfinite(f_col[:, 0]))

            if len(MIDI_val) > 1:
                for pri in range(0, len(pri_cnt_c)):
                    for sub_r in range(1, 6):
                        for sub_c in range(0, len(f_sol_0[0, :])):
                            if pri == 0:
                                f_sol_0[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
                            if pri == 1:
                                f_sol_1[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
                            if pri == 2:
                                f_sol_2[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
                            if pri == 3:
                                f_sol_3[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
                            if pri == 4:
                                f_sol_4[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
                            if pri == 5:
                                f_sol_5[sub_r, sub_c] = abs(f_col[0, pri] - f_col[sub_r, sub_c])
            if len(pri_cnt_r) == 0 or len(pri_cnt_c) == 0:
                True_tab = np.copy(np.zeros((6, 18), dtype = np.int32))
            else:
                ck_sol_0 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_0 = np.copy(ck_sol_0)
                ck_sol_1 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_1 = np.copy(ck_sol_0)
                ck_sol_2 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_2 = np.copy(ck_sol_0)
                ck_sol_3 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_3 = np.copy(ck_sol_0)
                ck_sol_4 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_4 = np.copy(ck_sol_0)
                ck_sol_5 = np.zeros((len(pri_cnt_r) - 1, len(pri_cnt_c) - 1), dtype = np.int32)
                sol_ind_5 = np.copy(ck_sol_0)

                # Replace infinite values with high finite values for each solution
                for ck_sol in range(0, len(pri_cnt_c)):
                    for pri_sol_r in range(1, len(pri_cnt_r)):
                        for pri_sol_c in range(0, len(pri_cnt_c) - 1):  # Random - 1
                            if ck_sol == 0:
                                if np.any(np.isinf(f_sol_0[pri_sol_r, :])):
                                    avoid_0 = np.argwhere(np.isinf(f_sol_0[pri_sol_r, :]))
                                    f_sol_0[pri_sol_r, avoid_0] = 999
                            if ck_sol == 1:
                                if np.any(np.isinf(f_sol_1[pri_sol_r, :])):
                                    avoid_1 = np.argwhere(np.isinf(f_sol_1[pri_sol_r, :]))
                                    f_sol_1[pri_sol_r, avoid_1] = 999
                                ck_sol_1[0, pri_sol_c] = min(f_sol_1[pri_sol_r, :])
                            if ck_sol == 2:
                                if np.any(np.isinf(f_sol_2[pri_sol_r, :])):
                                    avoid_2 = np.argwhere(np.isinf(f_sol_2[pri_sol_r, :]))
                                    f_sol_2[pri_sol_r, avoid_2] = 999
                                ck_sol_2[0, pri_sol_c] = min(f_sol_2[pri_sol_r, :])
                            if ck_sol == 3:
                                if np.any(np.isinf(f_sol_3[pri_sol_r, :])):
                                    avoid_3 = np.argwhere(np.isinf(f_sol_3[pri_sol_r, :]))
                                    f_sol_3[pri_sol_r, avoid_3] = 999
                                ck_sol_3[0, pri_sol_c] = min(f_sol_3[pri_sol_r, :])
                            if ck_sol == 4:
                                if np.any(np.isinf(f_sol_4[pri_sol_r, :])):
                                    avoid_4 = np.argwhere(np.isinf(f_sol_4[pri_sol_r, :]))
                                    f_sol_4[pri_sol_r, avoid_4] = 999
                                ck_sol_4[0, pri_sol_c] = min(f_sol_4[pri_sol_r, :])
                            if ck_sol == 5:
                                if np.any(np.isinf(f_sol_5[pri_sol_r, :])):
                                    avoid_5 = np.argwhere(np.isinf(f_sol_5[pri_sol_r, :]))
                                    f_sol_5[pri_sol_r, avoid_5] = 999
                                ck_sol_5[0, pri_sol_c] = min(f_sol_5[pri_sol_r, :])

                # Determine "rating" for each solution
                tab_sol_0 = np.argmin(f_sol_0, axis = 1)
                min_sol_0 = np.min(f_sol_0, axis = 1)
                if np.any(np.isinf(min_sol_0[:])):
                    rep_0 = np.argwhere(np.isinf(min_sol_0[:]))
                    min_sol_0[rep_0] = 0
                tab_sol_1 = np.argmin(f_sol_1, axis = 1)
                min_sol_1 = np.min(f_sol_1, axis = 1)
                if np.any(np.isinf(min_sol_1[:])):
                    rep_1 = np.argwhere(np.isinf(min_sol_1[:]))
                    min_sol_1[rep_1] = 0
                tab_sol_2 = np.argmin(f_sol_2, axis = 1)
                min_sol_2 = np.min(f_sol_2, axis = 1)
                if np.any(np.isinf(min_sol_2[:])):
                    rep_2 = np.argwhere(np.isinf(min_sol_2[:]))
                    min_sol_2[rep_2] = 0
                tab_sol_3 = np.argmin(f_sol_3, axis = 1)
                min_sol_3 = np.min(f_sol_3, axis = 1)
                if np.any(np.isinf(min_sol_3[:])):
                    rep_3 = np.argwhere(np.isinf(min_sol_3[:]))
                    min_sol_3[rep_3] = 0
                tab_sol_4 = np.argmin(f_sol_4, axis = 1)
                min_sol_4 = np.min(f_sol_4, axis = 1)
                if np.any(np.isinf(min_sol_4[:])):
                    rep_4 = np.argwhere(np.isinf(min_sol_4[:]))
                    min_sol_4[rep_4] = 0
                tab_sol_5 = np.argmin(f_sol_5, axis = 1)
                min_sol_5 = np.min(f_sol_5, axis = 1)
                if np.any(np.isinf(min_sol_5[:])):
                    rep_5 = np.argwhere(np.isinf(min_sol_5[:]))
                    min_sol_5[rep_5] = 0
                sol_0 = np.sum(min_sol_0[:])
                sol_1 = np.sum(min_sol_1[:])
                sol_2 = np.sum(min_sol_2[:])
                sol_3 = np.sum(min_sol_3[:])
                sol_4 = np.sum(min_sol_4[:])
                sol_5 = np.sum(min_sol_4[:])

            # Initalize variables
            acc_sol = False
            idx_pass = False

            # Choose best solution based on previous rating
            if len(pri_cnt_c) == 1:
                fin_sol_arr = sol_0
            if len(pri_cnt_c) == 2:
                fin_sol_arr = np.append(sol_0, sol_1)
            if len(pri_cnt_c) == 3:
                fin_sol_arr = np.append(np.append(sol_0, sol_1), sol_2)
            if len(pri_cnt_c) == 4:
                fin_sol_arr = np.append(np.append(sol_0, sol_1), np.append(sol_2, sol_3))
            if len(pri_cnt_c) == 5:
                fin_sol_arr = np.array(np.append(np.append(sol_0, sol_1), np.append(sol_2, sol_3)), sol_4)
            if len(pri_cnt_c) == 6:
                fin_sol_arr = np.array(np.append(np.append(sol_0, sol_1), np.append(sol_2, sol_3)), np.append(sol_4, sol_5))
            fin_choice = np.argmin(fin_sol_arr)
            response, ret_cnts, ret_idx = np.unique(fin_sol_arr, return_counts = True, return_index = True)
            ret_idx = [np.argwhere(idx_cnt == fin_sol_arr) for idx_cnt in np.unique(fin_sol_arr)]
            for idx_cnt_row in range(0, len(ret_idx)):
                if np.amin(response) == np.amin(fin_sol_arr) and len(ret_idx[idx_cnt_row]) > 2:
                    fin_sol_arr = np.delete(fin_sol_arr, np.argwhere(np.amin(fin_sol_arr)))
            if np.amin(response) == np.amin(fin_sol_arr) and ret_cnts[np.argwhere(np.amin(fin_sol_arr))] > 2:
                fin_sol_arr = np.delete(fin_sol_arr, np.argwhere(np.amin(fin_sol_arr)))
                fin_choice = np.argmin(fin_sol_arr)

            # Choose solution and choose the next best solution if there are two notes on one string
            while acc_sol == False:
                fin_tab_row = np.zeros((len(pri_cnt_r)), dtype = np.int32)
                fin_tab_col = np.zeros((len(pri_cnt_r)), dtype = np.int32)
                if fin_choice == 0:
                    fin_tab_row[0] = f_row[0, 0]
                    fin_tab_col[0] = f_col[0, 0]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_0[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_0[counter]]
                if fin_choice == 1:
                    fin_tab_row[0] = f_row[0, 1]
                    fin_tab_col[0] = f_col[0, 1]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_1[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_1[counter]]
                if fin_choice == 2:
                    fin_tab_row[0] = f_row[0, 2]
                    fin_tab_col[0] = f_col[0, 2]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_2[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_2[counter]]
                if fin_choice == 3:
                    fin_tab_row[0] = f_row[0, 3]
                    fin_tab_col[0] = f_col[0, 3]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_3[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_3[counter]]
                if fin_choice == 4:
                    fin_tab_row[0] = f_row[0, 4]
                    fin_tab_col[0] = f_col[0, 4]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_4[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_4[counter]]
                if fin_choice == 5:
                    fin_tab_row[0] = f_row[0, 5]
                    fin_tab_col[0] = f_col[0, 5]
                    for counter in range(1, len(pri_cnt_r)):
                        fin_tab_row[counter] = f_row[counter, tab_sol_5[counter]]
                        fin_tab_col[counter] = f_col[counter, tab_sol_5[counter]]
                acc_sol = True
                idx_cnt = [np.argwhere(uni_cnt == fin_tab_row) for uni_cnt in np.unique(fin_tab_row)]
                max_len_cnt = np.zeros((len(idx_cnt)), dtype = np.int32)
                for str_cnt_row in range(0, len(idx_cnt)):
                    if len(idx_cnt[str_cnt_row]) > 1:
                        fin_sol_arr = fin_sol_arr.astype('int64')
                        if fin_sol_arr.size > 1:
                            fin_sol_arr = np.delete(fin_sol_arr, fin_choice)
                            idx_pass = True
                            acc_sol = False
                            break
                        else:
                            continue
                fin_choice = np.argmin(fin_sol_arr)
            fin_tab_row = abs(fin_tab_row - 5)

            # Return the final tab
            True_tab = np.copy(np.zeros((6, 18), dtype = np.int32))
            for tt_cnt in range(0, len(fin_tab_col)):
                True_tab[fin_tab_row[tt_cnt], fin_tab_col[tt_cnt]] = 1

            # Add column to final tab that identifies whether that the string is not being played
            True_tab = np.c_[np.zeros(6, dtype = np.int32), True_tab]
            value = 1
            for i in range(6):
                if value not in True_tab[i, :]:
                    True_tab[i, 0] = 1

            return True_tab
        else:
            return None
        
    def get_times(self, n):
        file_audio = os.path.join(self.path_audio, os.listdir(self.path_audio)[n])
        (source_rate, source_sig) = wavfile.read(file_audio)
        duration_seconds = len(source_sig) / float(source_rate)
        totalFrame = math.ceil(duration_seconds / self.frameDuration)
        frame_indices = list(range(totalFrame))
        times = librosa.frames_to_time(frame_indices, sr = self.sr_downs, hop_length = self.hop_length)
        return times

    def save_data(self, filename):
        np.savez(filename, **self.output)
               
    def get_filename(self, n):
        filename = os.path.basename(os.path.join(self.path_anno, os.listdir(self.path_anno)[n]))
        return filename[:-5]
    
    def log(self, text):
        text = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " | " + text + "\n"
        with open("log/dataGen.log", "a") as myfile:
            myfile.write(text)
            print(text)

    def store(self, n, num_frames):
        save_path = self.save_path
        filename = self.get_filename(n)
               
        self.output["labels"] = self.labels
        self.output["img"] = self.img

        if not os.path.exists(save_path):
            os.makedirs(save_path)
        self.save_data(save_path + filename + ".npz")
        self.log("done file n. " + str(n+1) + ": " + filename + ", " + str(num_frames) + " frames")
   
    def load(self, n):
        times = self.get_times(n)

        for t in range(len(times)-1):
            True_tab = self.spacejam(n, times[t], times[t+1])
            if(True_tab is None):
                continue

            cqt = self.audio_CQT(n, times[t], times[t+1]-times[t])
            if(cqt.max() == cqt.min() == 0):
                continue

            self.labels.append(True_tab)
            self.img.append(cqt)

        self.store(n, len(times))
        self.output = {}
        self.labels = []
        self.img = []

def main(args):
    path = args[0]
    n = args[1]
    gen = dataGen(path)
    gen.log("start file n. " + str(n+1))
    gen.load(n)

if __name__ == "__main__":
    main(args)