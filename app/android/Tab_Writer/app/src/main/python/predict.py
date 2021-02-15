import numpy as np
import tensorflow as tf
import json

path_model = "/data/user/0/com.unibo.tab_writer/files/chaquopy/AssetFinder/app/model.tflite"
data_json = []

def myconverter(obj):
	if isinstance(obj, np.integer):
		return int(obj)
	elif isinstance(obj, np.floating):
		return float(obj)
	elif isinstance(obj, np.ndarray):
		return obj.tolist()
	elif isinstance(obj, datetime.datetime):
		return obj.__str__()

def predict_model(images):
	# Load the TFLite model and allocate tensors.
	interpreter = tf.lite.Interpreter(model_path=path_model)
	interpreter.allocate_tensors()

	# Get input and output tensors.
	input_details = interpreter.get_input_details()			# [{'name': 'conv2d_1_input', 'index': 46, 'shape': array([  1, 192,   9,   1]), 'dtype': <class 'numpy.float32'>, 'quantization': (0.0, 0)}]
	output_details = interpreter.get_output_details()		# [{'name': 'activation_1/concat', 'index': 18, 'shape': array([ 1,  6, 19]), 'dtype': <class 'numpy.float32'>, 'quantization': (0.0, 0)}]

#	input_shape = input_details[0]['shape']
#	print(input_shape) 										# [  1 192   9   1]
#	print(images[0].shape) 									# (192, 9, 1)
#	print(images.shape)										# (15, 192, 9, 1)
	
#	input_data = np.array(images[0], dtype=np.float32)


	for i in range(images.shape[0]):
		input_data = images[i].reshape(1, images.shape[1], images.shape[2], images.shape[3])

		interpreter.set_tensor(input_details[0]['index'], input_data)
		interpreter.invoke()

		output_data = interpreter.get_tensor(output_details[0]['index'])

		b = np.zeros_like(np.squeeze(output_data))
		b[np.arange(len(np.squeeze(output_data))), np.argmax(np.squeeze(output_data),axis=-1)] = 1

		check = 1
		for n in range(6):
			value = np.argmax(b.astype('int32')[:, 1:], axis=1)[n]
			
			if value == 0:
				if check == 6:
					data_json.append({'tab_x' : i, 'tab_y' : n, 'value' : value})
				check = check + 1
			else:
				data_json.append({'tab_x' : i, 'tab_y' : n, 'value' : value})



#		if i == 0:
#			arr = output_data

#		arr = np.append(arr, output_data, axis=0)

	return json.dumps(data_json, default=myconverter)

	