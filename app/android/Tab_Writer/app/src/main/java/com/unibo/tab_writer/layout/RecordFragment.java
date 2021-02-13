package com.unibo.tab_writer.layout;

import android.Manifest;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.SystemClock;
import android.preference.PreferenceManager;
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

import com.arthenica.mobileffmpeg.Config;
import com.arthenica.mobileffmpeg.FFmpeg;
import com.chaquo.python.PyObject;
import com.chaquo.python.Python;
import com.unibo.tab_writer.R;
import com.unibo.tab_writer.database.DatabaseHelper;
import com.unibo.tab_writer.database.DbAdapter;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
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

    private String ipv4Address;
    private String portNumber;

//    private String ipv4Address = "s3rv3r2020.duckdns.org";
//    private String portNumber = "5000";
    private OkHttpClient client = new OkHttpClient();

    private DbAdapter dbHelper;
    private long cursor;


    public RecordFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        dbHelper = new DbAdapter(getContext());
        dbHelper.open();

        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(getContext());
        ipv4Address = sharedPreferences.getString("ip", "192.168.1.1");
        portNumber = sharedPreferences.getString("port", "5000");

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

        recordText.setText("STO PENSANDO...");

//        Log.d("LOGGO",new File("file:///android_asset/fff.wav").getAbsolutePath());
//        String fname = new File(getActivity().getFilesDir(), "fff.wav").getAbsolutePath();
//        Log.d("LOGGO", path);
        connectServer(path);
    }

    private void startRecording(){
        timer.setBase(SystemClock.elapsedRealtime());
        timer.start();

        String recordPath = getActivity().getExternalFilesDir("/").getAbsolutePath();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss", Locale.ITALIAN);
        Date now = new Date();

        recordFile = "Guitar_Tab_" + formatter.format(now) + ".aac";

        recordText.setText("STO ASCOLTANDO...");

        mediaRecorder = new MediaRecorder();
        mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS);
        mediaRecorder.setOutputFile(recordPath + "/" + recordFile);
        mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
        mediaRecorder.setAudioSamplingRate(44100);

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
                .addFormDataPart("file", "rec.aac", RequestBody.create(new File(path), MediaType.parse("application/octet-stream")))
                .build();

        postRequest(postUrl, postBody);
    }


    private void postRequest(String postUrl, RequestBody postBody) {
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
                            //Toast.makeText(getActivity(), response.body().string(), Toast.LENGTH_LONG).show();

                            String jsonData = response.body().string();
                            JSONObject Jobject = null;
                            try {
                                Jobject = new JSONObject(jsonData);
                                JSONArray tab = Jobject.getJSONArray("tab");
                                Log.d("LOGGO", tab.toString());

                                // salva json
                                cursor = dbHelper.createTab(recordFile, "data", "tab", tab.toString());

                                int rc = FFmpeg.execute("-i " + path + " -acodec pcm_u8 -ar 44100 " + path + ".wav");

                                Python py = Python.getInstance();
                                final PyObject pyobj = py.getModule("preprocessing");

                                PyObject obj = pyobj.callAttr("preprocessing_file", path + ".wav");
                                Log.d("LOGGO", obj.toString());



                                // passa info fragment


                                FragmentManager fragmentManager = getActivity().getSupportFragmentManager();
                                FragmentTransaction fragmentTransaction=fragmentManager.beginTransaction();
                                fragmentTransaction.replace(R.id.navHostFragment, new TabViewFragment(), "TabViewFragment");
                                fragmentTransaction.addToBackStack(null);
                                fragmentTransaction.commit();
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        } catch (IOException e){
                            e.printStackTrace();
                        }
                    }
                });
            }
        });
    }
}