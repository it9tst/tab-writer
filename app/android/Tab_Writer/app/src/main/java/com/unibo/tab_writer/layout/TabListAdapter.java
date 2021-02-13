package com.unibo.tab_writer.layout;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.unibo.tab_writer.R;
import com.unibo.tab_writer.utils.TimeAgo;

import java.io.File;
import java.util.ArrayList;

public class TabListAdapter extends RecyclerView.Adapter<TabListAdapter.TabViewHolder> {

    private int count;
    private ArrayList tab_title;
    private ArrayList tab_date;
    private TimeAgo timeAgo;
    private onItemListClick onItemListClick;

    public TabListAdapter(int count, ArrayList tab_title, ArrayList tab_date, onItemListClick onItemListClick){
        this.count = count;
        this.tab_title = tab_title;
        this.tab_date = tab_date;
        this.onItemListClick = onItemListClick;
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
        holder.list_title.setText(this.tab_title.get(position).toString());
        holder.list_date.setText(this.tab_date.get(position).toString());
    }

    @Override
    public int getItemCount() {
        return this.count;
    }

    public class TabViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private ImageView list_tab;
        private TextView list_title;
        private TextView list_date;

        public TabViewHolder(@NonNull View itemView) {
            super(itemView);

            list_tab = itemView.findViewById(R.id.list_tab);
            list_title = itemView.findViewById(R.id.list_title);
            list_date = itemView.findViewById(R.id.list_date);

            itemView.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            onItemListClick.onClickListener(getAdapterPosition());
        }
    }

    public interface onItemListClick {
        void onClickListener(int position);
    }
}
