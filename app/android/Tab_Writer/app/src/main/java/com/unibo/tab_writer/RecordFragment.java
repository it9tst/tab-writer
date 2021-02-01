package com.unibo.tab_writer;

import android.Manifest;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Chronometer;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;


public class RecordFragment extends Fragment implements View.OnClickListener{

    private ImageView recordBtn;
    private TextView recordText;

    private boolean isRecording = false;

    private String recordPermission = Manifest.permission.RECORD_AUDIO;
    private int PERMISSION_CODE = 21;

    private MediaRecorder mediaRecorder;
    private String recordFile;

    private Chronometer timer;

    private TabModel tabModel;


    public RecordFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
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

        recordText.setText("STO PENSANDO...");

        mediaRecorder.stop();
        mediaRecorder.release();
        mediaRecorder = null;

        // continuare con l'elaborazione -> model
    }

    private void startRecording(){
        timer.setBase(SystemClock.elapsedRealtime());
        timer.start();

        String recordPath = getActivity().getExternalFilesDir("/").getAbsolutePath();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss", Locale.ITALIAN);
        Date now = new Date();

        recordFile = "Guitar_Tab_" + formatter.format(now) + ".3gp";

//        recordText.setText(tabModel.getTabModel());
        recordText.setText("STO ASCOLTANDO...");

        mediaRecorder = new MediaRecorder();
        mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mediaRecorder.setOutputFile(recordPath + "/" + recordFile);
        mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

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
}