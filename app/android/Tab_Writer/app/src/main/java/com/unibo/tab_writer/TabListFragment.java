package com.unibo.tab_writer;

import android.content.pm.ActivityInfo;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.io.File;


public class TabListFragment extends Fragment {

    private RecyclerView tabList;

    private File[] allFiles;

    private TabListAdapter tabListAdapter;


    public TabListFragment() {
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
        return inflater.inflate(R.layout.fragment_tab_list, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tabList = view.findViewById(R.id.tab_list_view);

        String path = getActivity().getExternalFilesDir("/").getAbsolutePath();
        File directory = new File(path);
        allFiles = directory.listFiles();

        tabListAdapter = new TabListAdapter(allFiles);

        tabList.setHasFixedSize(true);
        tabList.setLayoutManager(new LinearLayoutManager(getContext()));
        tabList.setAdapter(tabListAdapter);

    }
}