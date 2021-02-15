import flask
import werkzeug
import os
from preprocessing import preprocessing_file
from predict import predict_model
from flask import jsonify

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
    
    ffmpeg(filename)
    

#    images = preprocessing_file(filename)
#    result = predict_model(images)

    return jsonify({"message":"ok", "tab": [{'tab_y': 5, 'tab_x': 0, 'value': 0}, {'tab_y': 5, 'tab_x': 1, 'value': 0}, {'tab_y': 5, 'tab_x': 2, 'value': 12}, {'tab_y': 5, 'tab_x': 3, 'value': 0}, {'tab_y': 5, 'tab_x': 4, 'value': 0}, {'tab_y': 5, 'tab_x': 5, 'value': 10}, {'tab_y': 5, 'tab_x': 6, 'value': 8}, {'tab_y': 5, 'tab_x': 7, 'value': 10}, {'tab_y': 5, 'tab_x': 8, 'value': 10}, {'tab_y': 5, 'tab_x': 9, 'value': 12}, {'tab_y': 5, 'tab_x': 10, 'value': 13}, {'tab_y': 5, 'tab_x': 11, 'value': 15}, {'tab_y': 5, 'tab_x': 12, 'value': 15}, {'tab_y': 5, 'tab_x': 13, 'value': 0}, {'tab_y': 5, 'tab_x': 14, 'value': 0}, {'tab_y': 5, 'tab_x': 15, 'value': 0}, {'tab_y': 5, 'tab_x': 16, 'value': 0}, {'tab_y': 5, 'tab_x': 17, 'value': 15}, {'tab_y': 5, 'tab_x': 18, 'value': 0}, {'tab_y': 5, 'tab_x': 19, 'value': 10}, {'tab_y': 5, 'tab_x': 20, 'value': 0}, {'tab_y': 5, 'tab_x': 21, 'value': 10}, {'tab_y': 5, 'tab_x': 22, 'value': 0}, {'tab_y': 5, 'tab_x': 23, 'value': 3}, {'tab_y': 5, 'tab_x': 24, 'value': 0}]})
#    return jsonify({"message":"ok"})

def ffmpeg(i):
    os.system("""ffmpeg.exe -i {i} -acodec pcm_u8 -ar 44100 {i[:-4]}.wav""")

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)