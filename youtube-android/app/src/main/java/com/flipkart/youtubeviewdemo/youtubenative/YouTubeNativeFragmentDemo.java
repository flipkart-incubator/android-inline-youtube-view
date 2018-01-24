package com.flipkart.youtubeviewdemo.youtubenative;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.flipkart.youtubeviewdemo.R;

import java.util.ArrayList;

public class YouTubeNativeFragmentDemo extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        RecyclerView view = (RecyclerView) inflater.inflate(R.layout.youtube_native_fragment, container, false);

        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getContext());
        view.setLayoutManager(linearLayoutManager);

        Bundle arguments = getArguments();
        int playerType = arguments.getInt("playerType");

        ArrayList<String> videoIds = new ArrayList<>();
        videoIds.add("2Vv-BfVoq4g");
        videoIds.add("D5drYkLiLI8");
        videoIds.add("K0ibBPhiaG0");
        videoIds.add("ebXbLfLACGM");
        videoIds.add("mWRsgZuwf_8");

        YouTubePlayerAdapter youTubePlayerAdapter = new YouTubePlayerAdapter(getContext(), videoIds, this, playerType);
        view.setAdapter(youTubePlayerAdapter);

        return view;
    }
}
