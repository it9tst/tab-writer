import flask
import werkzeug
import os
import numpy as np
from preprocessing import preprocessing_file
from flask import jsonify
from pydub import AudioSegment

from predict import predict_model

app = flask.Flask(__name__)

@app.route('/')
def hello_world():
    print(__name__)
    return 'Hello Ani'

@app.route('/upload/', methods = ['POST'])
def handle_request():
    audiofile = flask.request.files['file']
    filename = werkzeug.utils.secure_filename(audiofile.filename)
    print("\nReceived audio File name : " + audiofile.filename)
    audiofile.save(filename)
    
    try:
        dirpath = os.path.dirname(os.path.abspath(filename))
        filepath = dirpath + '/' + filename
        (path, file_extension) = os.path.splitext(filepath)
        file_extension_final = file_extension.replace('.', '')
        track = AudioSegment.from_file(filepath, file_extension_final)
        wav_filename = filename.replace(file_extension_final, 'wav')
        wav_path = dirpath + '/' + wav_filename
        print('CONVERTING: ' + str(filepath))
        file_handle = track.export(wav_path, format='wav')
        os.remove(filepath)
    except:
        print("ERROR CONVERTING")
    
    images = preprocessing_file(wav_filename)
    #images = preprocessing_file(filename)
    print(images.shape)
    #images = np.swapaxes(images,1,2)
    #images = np.swapaxes(images,1,3)
    #print(images.shape)
    #print(images)
    #np.savetxt("nxx", images.reshape((3,-1)), fmt="%s", header=str(images.shape))
    #result = predict_model(images)
    #print(result)
    
    os.remove(wav_path)
    
    return jsonify(images.tolist())

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
