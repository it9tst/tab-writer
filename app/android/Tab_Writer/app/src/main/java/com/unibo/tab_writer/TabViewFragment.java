package com.unibo.tab_writer;

import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
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

import java.util.ArrayList;

public class TabViewFragment extends Fragment {

    BubbleChart bubbleChart;

    public TabViewFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_tab_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

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
        xAxis.setAxisMaximum(7.5f);

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

        ArrayList<BubbleEntry> tab = new ArrayList<>();
        tab.add(new BubbleEntry(0, 0, 13));
        tab.add(new BubbleEntry(1, 0, 11));
        tab.add(new BubbleEntry(1, 1, 13));
        tab.add(new BubbleEntry(3, 2, 13));
        tab.add(new BubbleEntry(4, 3, 3));
        tab.add(new BubbleEntry(4, 4, 4));
        tab.add(new BubbleEntry(5, 3, 10));
        tab.add(new BubbleEntry(6, 5, 11));
        tab.add(new BubbleEntry(7, 3, 3));

        BubbleDataSet bubbleDataSet = new BubbleDataSet(tab, "tab");
        bubbleDataSet.setColor(Color.WHITE, 0);
        bubbleDataSet.setValueTextColor(Color.WHITE);
        bubbleDataSet.setValueTextSize(16f);
        bubbleDataSet.setValueFormatter(new DefaultValueFormatter(0));

        BubbleData bubbleData = new BubbleData(bubbleDataSet);
        bubbleChart.setData(bubbleData);
        bubbleChart.setVisibleXRangeMaximum(8f);
    }
}