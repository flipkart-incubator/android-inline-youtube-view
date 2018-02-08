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
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.flipkart.youtubeview.R;
import com.flipkart.youtubeview.listener.YouTubeEventListener;
import com.flipkart.youtubeview.webview.YouTubePlayerWebView;

public final class YouTubeWebViewFragment extends Fragment implements YouTubeEventListener, YouTubeBaseFragment {

    private static final String WEB_VIEW_URL = "webViewUrl";
    private static final String VIDEO_ID = "videoId";
    private YouTubePlayerWebView youTubePlayerWebView = null;

    @Nullable
    private YouTubeEventListener youTubeEventListener;

    public static YouTubeWebViewFragment newInstance(@NonNull String webViewUrl, @NonNull String videoId) {
        YouTubeWebViewFragment youTubeWebViewFragment = new YouTubeWebViewFragment();
        Bundle bundle = new Bundle();
        bundle.putString(WEB_VIEW_URL, webViewUrl);
        bundle.putString(VIDEO_ID, videoId);
        youTubeWebViewFragment.setArguments(bundle);
        return youTubeWebViewFragment;
    }

    @Override
    public void setYouTubeEventListener(@Nullable YouTubeEventListener listener) {
        youTubeEventListener = listener;
    }

    @Override
    public void release() {
        if (youTubePlayerWebView != null) {
            youTubePlayerWebView.stopPlayer();
        }
    }

    public void setWebView(@NonNull YouTubePlayerWebView webView) {
        youTubePlayerWebView = webView;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Bundle arguments = getArguments();
        String webViewUrl = arguments != null ? arguments.getString(WEB_VIEW_URL) : null;
        if (TextUtils.isEmpty(webViewUrl)) {
            throw new IllegalStateException("webViewUrl cannot be null");
        }
        return bindYoutubePlayerWebView(inflater, container, webViewUrl);
    }

    private YouTubePlayerWebView bindYoutubePlayerWebView(LayoutInflater inflater, @Nullable ViewGroup container, @NonNull String webViewUrl) {
        if (youTubePlayerWebView == null) {
            youTubePlayerWebView = (YouTubePlayerWebView) inflater.inflate(R.layout.youtube_player_web_view, container, false);
            youTubePlayerWebView.initialize(webViewUrl);
            youTubePlayerWebView.setYouTubeListener(this);
            setWebViewProps();
            //on ready event will be fired by default
        } else {
            removeWebView();
            youTubePlayerWebView.initialize(webViewUrl);
            youTubePlayerWebView.setYouTubeListener(this);
            setWebViewProps();
            youTubePlayerWebView.onReadyPlayer();
        }
        return youTubePlayerWebView;
    }

    private void setWebViewProps() {
        youTubePlayerWebView.resetTime();
    }

    public YouTubePlayerWebView removeWebView() {
        youTubePlayerWebView.stopPlayer();
        return youTubePlayerWebView;
    }

    @Override
    public void onReady() {
        Bundle arguments = getArguments();
        String videoId = arguments != null ? arguments.getString(VIDEO_ID) : null;
        youTubePlayerWebView.loadVideo(videoId);
        if (youTubeEventListener != null) {
            youTubeEventListener.onReady();
        }
    }

    @Override
    public void onPlay(int currentTime) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onPlay(currentTime);
        }
    }

    @Override
    public void onPause(int currentTime) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onPause(currentTime);
        }
    }

    @Override
    public void onStop(int currentTime, int totalDuration) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onStop(currentTime, totalDuration);
        }
    }

    @Override
    public void onBuffering(int currentTime, boolean isBuffering) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onBuffering(currentTime, isBuffering);
        }
    }

    @Override
    public void onSeekTo(int currentTime, int newPositionMillis) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onSeekTo(currentTime, newPositionMillis);
        }
    }

    @Override
    public void onInitializationFailure(String error) {
        if (youTubeEventListener != null) {
            youTubeEventListener.onInitializationFailure(error);
        }
    }

    @Override
    public void onNativeNotSupported() {
        if (youTubeEventListener != null) {
            youTubeEventListener.onNativeNotSupported();
        }
    }

    @Override
    public void onCued() {
        if (youTubeEventListener != null) {
            youTubeEventListener.onCued();
        }
    }
}
