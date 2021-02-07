package com.unibo.tab_writer;

import android.Manifest;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Chronometer;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class RecordFragment extends Fragment implements View.OnClickListener{

    private ImageView recordBtn;
    private TextView recordText;

    private boolean isRecording = false;

    private String recordPermission = Manifest.permission.RECORD_AUDIO;
    private int PERMISSION_CODE = 21;

    private MediaRecorder mediaRecorder;
    private String recordFile;

    private Chronometer timer;

    private String path;

    private String ipv4Address = "s3rv3r2020.duckdns.org";
    private String portNumber = "5000";
    OkHttpClient client = new OkHttpClient();

    public RecordFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        String postUrl= "http://"+ipv4Address+":"+portNumber+"/";

        Request request = new Request.Builder().url(postUrl).build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getActivity(), "Network not found 1", Toast.LENGTH_LONG).show();
                        recordText.setText("NETWORK NOT FOUND");
                    }
                });
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        try {
                            Toast.makeText(getActivity(), response.body().string(), Toast.LENGTH_LONG).show();
                            recordText.setText("PRESS THE BUTTON\nTO START RECORDING");
                            recordBtn.setClickable(true);
                        } catch (IOException e){
                            e.printStackTrace();
                        }
                    }
                });
            }
        });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_record, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        recordBtn = view.findViewById(R.id.record_btn);
        timer = view.findViewById(R.id.record_timer);
        recordText = view.findViewById(R.id.record_text);

        recordBtn.setOnClickListener(this);
        recordBtn.setClickable(false);

    }

    @Override
    public void onClick(View v){
        switch (v.getId()){
            case R.id.record_btn:
                if(isRecording){
                    stopRecording();
                    recordBtn.setImageDrawable(getResources().getDrawable(R.drawable.rec_button_off));
                    isRecording = false;
                } else {
                    if(checkPermissions()){
                        startRecording();
                        recordBtn.setImageDrawable(getResources().getDrawable(R.drawable.rec_button_on));
                        isRecording = true;
                    }
                }
        }
    }

    private void stopRecording(){
        timer.stop();

        mediaRecorder.stop();
        mediaRecorder.release();
        mediaRecorder = null;

//        Log.d("LOGGO",new File("file:///android_asset/fff.wav").getAbsolutePath());
//        String fname = new File(getActivity().getFilesDir(), "fff.wav").getAbsolutePath();
        connectServer(path);
    }

    private void startRecording(){
        timer.setBase(SystemClock.elapsedRealtime());
        timer.start();

        String recordPath = getActivity().getExternalFilesDir("/").getAbsolutePath();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss", Locale.ITALIAN);
        Date now = new Date();

        recordFile = "Guitar_Tab_" + formatter.format(now) + ".3gp";

        recordText.setText("STO ASCOLTANDO...");

        mediaRecorder = new MediaRecorder();
        mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mediaRecorder.setOutputFile(recordPath + "/" + recordFile);
        mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

        path = recordPath + "/" + recordFile;

        try {
            mediaRecorder.prepare();
        } catch (IOException e){
            e.printStackTrace();
        }

        mediaRecorder.start();
    }

    private boolean checkPermissions(){
        if(ActivityCompat.checkSelfPermission(getContext(), recordPermission) == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            ActivityCompat.requestPermissions(getActivity(), new String[]{recordPermission}, PERMISSION_CODE);
            return false;
        }

    }

    private void connectServer(String path) {
        String postUrl= "http://"+ipv4Address+":"+portNumber+"/upload/";

        RequestBody postBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("file", "androidFlask.3gp", RequestBody.create(MediaType.parse("application/octet-stream"), path))
                .build();

        postRequest(postUrl, postBody);
    }

    private void postRequest(String postUrl, RequestBody postBody) {
        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(postUrl)
                .post(postBody)
                .build();

        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getActivity(), "Network not found 2", Toast.LENGTH_LONG).show();
                        recordText.setText("NETWORK NOT FOUND");
                    }
                });
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        try {
                            recordText.setText("STO PENSANDO...");

                            String jsonData = response.body().string();
                            JSONObject Jobject = new JSONObject(jsonData);
                            JSONArray Jarray = Jobject.getJSONArray("employees");

                            //define the strings that will temporary store the data
                            String tab_x, tab_y, value;

                            //get the length of the json array
                            int limit = Jarray.length()

                            //datastore array of size limit
                            String dataStore[] = new String[limit];

                            for (int i = 0; i < limit; i++) {
                                JSONObject object = Jarray.getJSONObject(i);

                                tab_x = object.getString("tab_x");
                                tab_y = object.getString("tab_y");
                                value = object.getString("value");

                                Log.d("JSON DATA", tab_x + " ## " + tab_y + " ## " + value);

                                //store the data into the array
                                dataStore[i] = tab_x + " ## " + tab_y + " ## " + value;
                            }

                            //prove that the data was stored in the array
                            for (String content ; dataStore) {
                                Log.d("ARRAY CONTENT", content);
                            }

                            FragmentManager fragmentManager = getActivity().getSupportFragmentManager();
                            FragmentTransaction fragmentTransaction=fragmentManager.beginTransaction();
                            fragmentTransaction.replace(R.id.navHostFragment, new TabViewFragment(), "TabViewFragment");
                            fragmentTransaction.addToBackStack(null);
                            fragmentTransaction.commit();
                        } catch (IOException e){
                            e.printStackTrace();
                        }
                    }
                });
            }
        });
    }
}