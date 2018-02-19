package com.flipkart.youtubeview.util;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.flipkart.youtubeview.models.YouTubePlayerType;

public class VideoConfig {
    @NonNull
    public String apiKey;
    @NonNull
    public String videoId;
    @NonNull
    public String webViewUrl;
    @Nullable
    public String thumbnailUrl;
    @YouTubePlayerType
    public int playerType;

    public VideoConfig(@NonNull String apiKey, @NonNull String videoId, @NonNull String webViewUrl) {
        this.apiKey = apiKey;
        this.videoId = videoId;
        this.webViewUrl = webViewUrl;
    }
}
