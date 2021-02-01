package com.unibo.tab_writer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;

public class TabListAdapter extends RecyclerView.Adapter<TabListAdapter.TabViewHolder> {

    private File[] allFiles;
    private TimeAgo timeAgo;

    public TabListAdapter(File[] allFiles){
        this.allFiles = allFiles;
    }

    @NonNull
    @Override
    public TabViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.single_list_item, parent, false);
        timeAgo = new TimeAgo();
        return new TabViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull TabViewHolder holder, int position) {
        holder.list_title.setText(allFiles[position].getName());
        holder.list_date.setText(timeAgo.getTimeAgo(allFiles[position].lastModified()));
    }

    @Override
    public int getItemCount() {
        return allFiles.length;
    }

    public class TabViewHolder extends RecyclerView.ViewHolder{

        private ImageView list_tab;
        private TextView list_title;
        private TextView list_date;

        public TabViewHolder(@NonNull View itemView) {
            super(itemView);

            list_tab = itemView.findViewById(R.id.list_tab);
            list_title = itemView.findViewById(R.id.list_title);
            list_date = itemView.findViewById(R.id.list_date);
        }
    }
}
