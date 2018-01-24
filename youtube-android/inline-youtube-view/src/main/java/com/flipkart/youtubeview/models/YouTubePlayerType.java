package com.flipkart.youtubeview.models;

import android.support.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({YouTubePlayerType.INVALID_VIEW, YouTubePlayerType.AUTO, YouTubePlayerType.STRICT_NATIVE, YouTubePlayerType.WEB_VIEW})
@Retention(RetentionPolicy.SOURCE)
public @interface YouTubePlayerType {
    /**
     * Invalid view
     */
    int INVALID_VIEW = 0;

    /**
     * Auto. If youtube service is available, it will render native player
     * else will fallback to WebView if web-url provided
     */
    int AUTO = 1;

    /**
     * render only native player
     */
    int STRICT_NATIVE = 2;

    /**
     * render only WebView player
     */
    int WEB_VIEW = 3;
}
