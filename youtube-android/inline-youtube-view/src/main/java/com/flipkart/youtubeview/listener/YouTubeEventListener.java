package com.flipkart.youtubeview.listener;

import android.support.annotation.MainThread;

public interface YouTubeEventListener {

    /**
     * fired when youtube player is ready
     */
    @MainThread
    void onReady();

    /**
     * when video is playing.
     *
     * @param currentTime currentTime of seek-bar
     */
    @MainThread
    void onPlay(int currentTime);

    /**
     * when video has been paused.
     *
     * @param currentTime paused time
     */
    @MainThread
    void onPause(int currentTime);

    /**
     * when video has been stopped
     *
     * @param currentTime   stop time
     * @param totalDuration total duration of video
     */
    @MainThread
    void onStop(int currentTime, int totalDuration);

    /**
     * when video is buffering
     *
     * @param currentTime current buffering time
     * @param isBuffering is video being buffered
     */
    @MainThread
    void onBuffering(int currentTime, boolean isBuffering);

    /**
     * when seek-bar is moved
     *
     * @param currentTime       time from where seek-bar has been moved
     * @param newPositionMillis new position moved
     */
    @MainThread
    void onSeekTo(int currentTime, int newPositionMillis);

    /**
     * when youtube player fails to initialize
     *
     * @param error message
     */
    @MainThread
    void onInitializationFailure(String error);

    /**
     * when native player is not supported
     */
    @MainThread
    void onNativeNotSupported();

    /**
     * when video is cued
     */
    @MainThread
    void onCued();
}
