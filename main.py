from multiprocessing import Pool
from dataGen import main

# define path data folder and n file
path = 'C:/Users/Gabriele/GitHub/tab-writer/data/'
n_file = 360

path_arr = [path] * 360
lists = list(range(0, n_file))

if __name__ == "__main__":
    p = Pool(5)
    p.map(main, zip(path_arr, lists))