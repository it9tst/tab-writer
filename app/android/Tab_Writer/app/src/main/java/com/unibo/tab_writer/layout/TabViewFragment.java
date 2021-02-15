package com.unibo.tab_writer.layout;

import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Color;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.github.mikephil.charting.charts.BubbleChart;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.BubbleData;
import com.github.mikephil.charting.data.BubbleDataSet;
import com.github.mikephil.charting.data.BubbleEntry;
import com.github.mikephil.charting.formatter.DefaultValueFormatter;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;
import com.unibo.tab_writer.R;
import com.unibo.tab_writer.database.DbAdapter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class TabViewFragment extends Fragment {

    private BubbleChart bubbleChart;
    private String tab_title;
    private String tab_tab;

    private DbAdapter dbHelper;
    private Cursor cursor;

    public TabViewFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        tab_title = getArguments().getString("tab_title");

        dbHelper = new DbAdapter(getContext());
        dbHelper.open();
        cursor = dbHelper.fetchTabsByFilter(tab_title);

        if (cursor.moveToFirst()){
            tab_tab = cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_TAB));
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        return inflater.inflate(R.layout.fragment_tab_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        ArrayList<BubbleEntry> tab = new ArrayList<>();

        Log.d("LOGGO-Tab-ViewFragment", tab_tab);

        JSONArray ja = null;
        try {
            ja = new JSONArray(tab_tab);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        ja.put(tab_tab);

        BubbleChart bubbleChart = view.findViewById(R.id.bubbleChart);
        bubbleChart.setTouchEnabled(true);
        bubbleChart.setDrawGridBackground(false);
        bubbleChart.setPinchZoom(false);
        bubbleChart.setDragEnabled(true);
        bubbleChart.getXAxis().setEnabled(false);
        bubbleChart.getAxisLeft().setEnabled(true);
        bubbleChart.getAxisRight().setEnabled(false);
        bubbleChart.getDescription().setEnabled(false);
        bubbleChart.getLegend().setEnabled(false);

        XAxis xAxis = bubbleChart.getXAxis();
        xAxis.setAxisMinimum(-0.5f);
        xAxis.setAxisMaximum(ja.length());

        YAxis yAxis = bubbleChart.getAxisLeft();
        yAxis.setValueFormatter(new IndexAxisValueFormatter(new String[]{"E","A","D","G","B","e"}));
        yAxis.setTextColor(Color.WHITE);
        yAxis.setTextSize(15f);
        yAxis.setDrawGridLines(true);
        yAxis.setGranularity(1f);
        yAxis.setGranularityEnabled(true);
        yAxis.setDrawZeroLine(false);
        yAxis.setAxisMinimum(0f);
        yAxis.setAxisMaximum(5f);


        for(int i=0; i < ja.length(); i++) {
            JSONObject jsonobject = null;
            try {
                jsonobject = ja.getJSONObject(i);
                tab.add(new BubbleEntry(Float.parseFloat(jsonobject.getString("tab_x")), getRealPosition(Float.parseFloat(jsonobject.getString("tab_y"))), Float.parseFloat(jsonobject.getString("value"))));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

/*
        Random r = new Random();

        for(int i=0; i<15; i++){
            tab.add(new BubbleEntry((float) r.nextInt(10), (float) r.nextInt(5), (float) r.nextInt(17)));
        }

        tab.add(new BubbleEntry(0, 0, 13));
        tab.add(new BubbleEntry(1, 0, 11));
        tab.add(new BubbleEntry(1, 1, 13));
        tab.add(new BubbleEntry(3, 2, 13));
        tab.add(new BubbleEntry(4, 3, 3));
        tab.add(new BubbleEntry(4, 4, 4));
        tab.add(new BubbleEntry(5, 3, 10));
        tab.add(new BubbleEntry(6, 5, 11));
        tab.add(new BubbleEntry(7, 3, 3));
        tab.add(new BubbleEntry(8, 4, 17));
        tab.add(new BubbleEntry(9, 3, 3));
        tab.add(new BubbleEntry(10, 1, 10));
        tab.add(new BubbleEntry(11, 2, 6));
*/
        BubbleDataSet bubbleDataSet = new BubbleDataSet(tab, "tab");
        bubbleDataSet.setColor(Color.WHITE, 0);
        bubbleDataSet.setValueTextColor(Color.WHITE);
        bubbleDataSet.setValueTextSize(16f);
        bubbleDataSet.setValueFormatter(new DefaultValueFormatter(0));

        BubbleData bubbleData = new BubbleData(bubbleDataSet);

        bubbleChart.setData(bubbleData);
        bubbleChart.setVisibleXRangeMaximum(9.5f);

        bubbleChart.animateXY(1000,1000);
    }

    private float getRealPosition(float p){
        float r = 0;
        switch ((int) p) {
            case 0:
                r = 5;
                break;
            case 1:
                r = 4;
                break;
            case 2:
                r = 3;
                break;
            case 3:
                r = 2;
                break;
            case 4:
                r = 1;
                break;
            case 5:
                r = 0;
                break;
        }
        return r;
    }
}