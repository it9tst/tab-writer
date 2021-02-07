import flask
import werkzeug
import preprocessing
import predict
from flask import jsonify

app = flask.Flask(__name__)

@app.route('/')
def hello_world():
    print(__name__)
    return 'Hello Ani'

@app.route('/upload', methods = ['GET', 'POST'])
def handle_request():
    audiofile = flask.request.files['file']
    filename = werkzeug.utils.secure_filename(audiofile.filename)
    print("\nReceived audio File name : " + audiofile.filename)
    audiofile.save(filename)

    images = preprocessing.preprocessing_file(filename)
    result = predict.predict_model(images)

    return jsonify(result)

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)