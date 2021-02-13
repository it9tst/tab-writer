package com.unibo.tab_writer.layout;

import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.unibo.tab_writer.R;
import com.unibo.tab_writer.database.DbAdapter;

import java.io.File;
import java.util.ArrayList;


public class TabListFragment extends Fragment implements TabListAdapter.onItemListClick {

    private RecyclerView tabList;
    private TabListAdapter tabListAdapter;

    private DbAdapter dbHelper;
    private Cursor cursor;

    private ArrayList<String> tab_title = new ArrayList<String>();
    private ArrayList<String> tab_date = new ArrayList<String>();


    public TabListFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);

        dbHelper = new DbAdapter(getContext());
        dbHelper.open();
        cursor = dbHelper.fetchAllTabs();
//        dbHelper.close();

        while(cursor.moveToNext()) {
            String title = cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_TITLE));
            String date = cursor.getString(cursor.getColumnIndex(DbAdapter.KEY_DATE));
            tab_title.add(title);
            tab_date.add(date);
        }

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

        // Initialize ArrayAdapter
        tabListAdapter = new TabListAdapter(cursor.getCount(), tab_title, tab_date, this);
        cursor.close();

        // Set ArrayAdapter to tabListAdapter
        tabList.setHasFixedSize(true);
        tabList.setLayoutManager(new LinearLayoutManager(getContext()));
        tabList.setAdapter(tabListAdapter);
    }

    @Override
    public void onClickListener(int position) {
        Log.d("LOGGO", tab_title.get(position));
        FragmentManager fragmentManager = getActivity().getSupportFragmentManager();
        FragmentTransaction fragmentTransaction=fragmentManager.beginTransaction();
        fragmentTransaction.replace(R.id.navHostFragment, new TabViewFragment(), "TabViewFragment");
        fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commit();
    }
}