package com.unibo.tab_writer.utils;

import android.content.Context;
import android.util.Log;


import org.tensorflow.lite.DataType;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

import java.io.IOException;
import java.nio.ByteBuffer;

public class Model {
/*
    private TensorBuffer outputFeature0;

    public Model(Context context) {

        String byteBuffer =

        try {
            Tab1 model = Tab1.newInstance(context);

            // Creates inputs for reference.
            TensorBuffer inputFeature0 = TensorBuffer.createFixedSize(new int[]{1, 192, 9, 1}, DataType.FLOAT32);
            inputFeature0.loadArray();

            // Runs model inference and gets result.
            Tab1.Outputs outputs = model.process(inputFeature0);
            outputFeature0 = outputs.getOutputFeature0AsTensorBuffer();

            // Releases model resources if no longer used.
            model.close();
        } catch (IOException e) {
            Log.e("tfliteSupport", "Error reading model", e);
        }
    }

    public String getOut(){
        return outputFeature0.toString();
    }
    */
}
