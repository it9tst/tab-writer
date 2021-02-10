import numpy as np
import keras
from keras.utils.generic_utils import get_custom_objects
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, Reshape, Activation
from keras.layers import Conv2D, MaxPooling2D, Conv1D, Lambda
from keras import backend as K


num_strings = 6
data_json = []

def softmax_by_string(t):
    sh = K.shape(t)
    string_sm = []
    for i in range(num_strings):
        string_sm.append(K.expand_dims(K.softmax(t[:,i,:]), axis=1))
    return K.concatenate(string_sm, axis=1)

def avg_acc(y_true, y_pred):
    return K.mean(K.equal(K.argmax(y_true, axis=-1), K.argmax(y_pred, axis=-1)))
    
def catcross_by_string(target, output):
    loss = 0
    for i in range(num_strings):
        loss += K.categorical_crossentropy(target[:,i,:], output[:,i,:])
    return loss

def predict_model(images):
    get_custom_objects().update({'softmax_by_string': Activation(softmax_by_string)})
    get_custom_objects().update({"avg_acc": avg_acc})
    get_custom_objects().update({"catcross_by_string": catcross_by_string})

    reconstructed_model = keras.models.load_model('tab.model')
    predict = reconstructed_model.predict(images)

    for i in range (len(predict)):
        prd = np.expand_dims(predict[i], axis=0)

        b = np.zeros_like(np.squeeze(prd))
        b[np.arange(len(np.squeeze(prd))), np.argmax(np.squeeze(prd),axis=-1)] = 1

        check = 1
        for n in range(6):
            value = np.argmax(b.astype('int32')[:, 1:], axis=1)[n]
        
            if value == 0:
                if check == 6:
                    data_json.append({'tab_x' : i, 'tab_y' : n, 'value' : value})
                check = check + 1
            else:
                data_json.append({'tab_x' : i, 'tab_y' : n, 'value' : value})

    return data_json