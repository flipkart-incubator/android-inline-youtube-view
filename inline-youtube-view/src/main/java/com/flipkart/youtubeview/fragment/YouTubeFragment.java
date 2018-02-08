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
package com.flipkart.youtubeview.fragment;

import android.os.Bundle;
import android.support.annotation.MainThread;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;

import com.flipkart.youtubeview.listener.YouTubeEventListener;
import com.flipkart.youtubeview.models.PlayerStateList;
import com.google.android.youtube.player.YouTubeInitializationResult;
import com.google.android.youtube.player.YouTubePlayer;
import com.google.android.youtube.player.YouTubePlayerSupportFragment;

public final class YouTubeFragment extends YouTubePlayerSupportFragment implements YouTubePlayer.OnInitializedListener, YouTubeBaseFragment {

    private static final String ARG_VIDEO_ID = "videoId";
    private static final String ARG_API_KEY = "apiKey";

    @PlayerStateList.PlayerState
    private String playerState = PlayerStateList.NONE;
    @Nullable
    private YouTubeEventListener listener;
    @Nullable
    private YouTubePlayer youTubePlayer;

    public static YouTubeFragment newInstance(@NonNull String apiKey, @NonNull final String videoId) {
        if (TextUtils.isEmpty(apiKey) || TextUtils.isEmpty(videoId)) {
            throw new IllegalStateException("VideoId and ApiKey cannot be null.");
        }
        YouTubeFragment youTubeFragment = new YouTubeFragment();
        Bundle bundle = new Bundle();
        bundle.putString(ARG_VIDEO_ID, videoId);
        bundle.putString(ARG_API_KEY, apiKey);
        youTubeFragment.setArguments(bundle);
        return youTubeFragment;
    }

    @Override
    public void setYouTubeEventListener(@Nullable YouTubeEventListener listener) {
        this.listener = listener;
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        /* release youTubePlayer when home button pressed. */
        release();
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (null == youTubePlayer) {
            Bundle arguments = getArguments();
            if (null != arguments) {
                initialize(arguments.getString(ARG_API_KEY), this);
            }
        }
    }

    @Override
    public void onInitializationSuccess(YouTubePlayer.Provider provider, final YouTubePlayer player, boolean restored) {
        youTubePlayer = player;
        youTubePlayer.setPlayerStyle(YouTubePlayer.PlayerStyle.DEFAULT);
        youTubePlayer.setShowFullscreenButton(false);

        if (listener != null) {
            listener.onReady();
        }

        youTubePlayer.setPlaybackEventListener(new YouTubePlayer.PlaybackEventListener() {
            @Override
            public void onPlaying() {
                if (listener != null && youTubePlayer != null && !PlayerStateList.PLAYING.equals(playerState)) {
                    playerState = PlayerStateList.PLAYING;
                    listener.onPlay(youTubePlayer.getCurrentTimeMillis());
                }
            }

            @Override
            public void onPaused() {
                handleOnPauseEvent();
            }

            @Override
            public void onStopped() {
                //since these are player stop events in case of any player error so pause event not stop.
                handleOnPauseEvent();
            }

            @Override
            public void onBuffering(boolean isBuffering) {
                if (listener != null && youTubePlayer != null) {
                    listener.onBuffering((youTubePlayer.getCurrentTimeMillis()), isBuffering);
                }
            }

            @Override
            public void onSeekTo(int newPositionMillis) {
                //just to mimick the pause event before play on seek event.
                handleOnPauseEvent();
            }
        });

        youTubePlayer.setPlayerStateChangeListener(new YouTubePlayer.PlayerStateChangeListener() {
            @Override
            public void onLoading() {
                //intentionally left blank
            }

            @Override
            public void onLoaded(String s) {
                //intentionally left blank
            }

            @Override
            public void onAdStarted() {
                //intentionally left blank
            }

            @Override
            public void onVideoStarted() {
                //intentionally left blank
            }

            @Override
            public void onVideoEnded() {
                handleStopEvent();
            }

            @Override
            public void onError(YouTubePlayer.ErrorReason errorReason) {
                //intentionally left blank
            }
        });

        if (!restored) {
            //do any work here to cue video, play video, etc.
            Bundle arguments = getArguments();
            String videoId = arguments != null ? arguments.getString(ARG_VIDEO_ID) : null;
            if (!TextUtils.isEmpty(videoId)) {
                youTubePlayer.loadVideo(videoId);
            }
        }
    }

    private void handleOnPauseEvent() {
        if (listener != null && youTubePlayer != null && (PlayerStateList.PLAYING.equals(playerState)
                || PlayerStateList.BUFFERING.equals(playerState))) {
            playerState = PlayerStateList.PAUSED;
            listener.onPause((youTubePlayer.getCurrentTimeMillis()));
        }
    }

    private void handleStopEvent() {
        if (listener != null && youTubePlayer != null && (PlayerStateList.PLAYING.equals(playerState)
                || PlayerStateList.BUFFERING.equals(playerState) || PlayerStateList.PAUSED.equals(playerState))) {
            playerState = PlayerStateList.STOPPED;
            listener.onStop((youTubePlayer.getCurrentTimeMillis()), (youTubePlayer.getDurationMillis()));
        }
    }

    @Override
    public void onInitializationFailure(YouTubePlayer.Provider provider, YouTubeInitializationResult result) {
        youTubePlayer = null;
        if (listener != null) {
            listener.onInitializationFailure(result.name());
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        handleStopEvent();
        release();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        release();
    }

    @MainThread
    public void release() {
        if (youTubePlayer != null) {
            youTubePlayer.release();
            youTubePlayer = null;
        }
    }
}
