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
