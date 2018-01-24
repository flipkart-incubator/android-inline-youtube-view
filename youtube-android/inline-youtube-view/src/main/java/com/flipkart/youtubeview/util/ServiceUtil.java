package com.flipkart.youtubeview.util;

import android.content.Context;

import com.google.android.youtube.player.YouTubeApiServiceUtil;
import com.google.android.youtube.player.YouTubeInitializationResult;
import com.google.android.youtube.player.YouTubeIntents;

public final class ServiceUtil {

    /**
     * Check if youtube service is available
     *
     * @param context {@link Context}
     * @return true if present, else false
     */
    public static boolean isYouTubeServiceAvailable(Context context) {
        return YouTubeIntents.isYouTubeInstalled(context) ||
                YouTubeApiServiceUtil.isYouTubeApiServiceAvailable(context) == YouTubeInitializationResult.SUCCESS;
    }
}
