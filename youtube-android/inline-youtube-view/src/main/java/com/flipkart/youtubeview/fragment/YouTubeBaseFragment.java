package com.flipkart.youtubeview.fragment;

import android.support.annotation.Nullable;

import com.flipkart.youtubeview.listener.YouTubeEventListener;

public interface YouTubeBaseFragment {

    void setYouTubeEventListener(@Nullable YouTubeEventListener listener);

    void release();
}
