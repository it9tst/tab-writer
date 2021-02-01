from multiprocessing import Pool
from dataGen import main
import datetime

# define path data folder and n file
path = 'C:/Users/Gabriele/GitHub/tab-writer/data/'
n_file = 360

path_arr = [path] * 360
lists = list(range(0, n_file))

def log(text):
    text = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " | " + text + "\n"
    with open("log/dataGen.log", "a") as myfile:
        myfile.write(text)
        print(text)
            
if __name__ == "__main__":
    log("###############################")
    log("###### INIT NEW DATA GEN ######")
    log("###############################")
    p = Pool(5)
    p.map(main, zip(path_arr, lists))