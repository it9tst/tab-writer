model = tf.keras.models.load_model("saved/model.h5", 
    custom_objects={'softmax_by_string': self.softmax_by_string, 
    'avg_acc': self.avg_acc, 'catcross_by_string': self.catcross_by_string})
		converter = lite.TFLiteConverter.from_keras_model(model)
		tflite_model = converter.convert()
		open("saved/model.tflite", "wb").write(tflite_model)