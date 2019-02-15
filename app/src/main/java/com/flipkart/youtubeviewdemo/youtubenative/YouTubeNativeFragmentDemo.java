/*
 * Apache License
 * Version 2.0, January 2004
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
 *
 * Copyright (c) 2018 Flipkart Internet Pvt. Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of the
 * License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */
package com.flipkart.youtubeviewdemo.youtubenative;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
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

        YouTubePlayerAdapter youTubePlayerAdapter = new YouTubePlayerAdapter(videoIds, this, playerType);
        view.setAdapter(youTubePlayerAdapter);

        return view;
    }
}
