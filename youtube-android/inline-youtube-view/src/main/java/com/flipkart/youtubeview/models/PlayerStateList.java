package com.flipkart.youtubeview.models;

import android.support.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@SuppressWarnings("WeakerAccess")
public class PlayerStateList {
    public static final String NOT_STARTED = "NOT_STARTED";
    public static final String ENDED = "ENDED";
    public static final String PLAYING = "PLAYING";
    public static final String PAUSED = "PAUSED";
    public static final String BUFFERING = "BUFFERING";
    public static final String CUED = "CUED";
    public static final String NONE = "NONE";
    public static final String STOPPED = "STOPPED";

    @StringDef({NOT_STARTED, ENDED, PLAYING, PAUSED, BUFFERING, CUED, NONE, STOPPED})
    @Retention(RetentionPolicy.SOURCE)
    public @interface PlayerState {
    }
}