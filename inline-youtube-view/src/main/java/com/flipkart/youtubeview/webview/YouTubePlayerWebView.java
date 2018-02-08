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
package com.flipkart.youtubeview.webview;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.flipkart.youtubeview.BuildConfig;
import com.flipkart.youtubeview.listener.YouTubeEventListener;
import com.flipkart.youtubeview.models.PlayerStateList;

public class YouTubePlayerWebView extends WebView {

    private static final String TAG = "YoutubePlayerWebView";
    private static final String SCHEME = "ytplayer";
    private static final String DATA_QUERY_PARAM = "data";
    private static final String CURRENT_TIME_PARAM = "currentTime";
    private static final String EVENT_CALLBACK = "callback";
    private static final int MULTIPLIER = 1000;
    private static final double ASPECT_RATIO = 0.5625; //aspect ratio of player 9:16(height/width)

    @Nullable
    private YouTubeEventListener youTubeListener;

    private String duration = null;
    private String currentTime = null;
    private String previousState = PlayerStateList.NONE;
    private boolean isPlayerReady = false;

    public YouTubePlayerWebView(Context context) {
        super(context);
    }

    public YouTubePlayerWebView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int newWidth;
        int newHeight;
        newWidth = getMeasuredWidth();
        newHeight = (int) (newWidth * ASPECT_RATIO);
        setMeasuredDimension(newWidth, newHeight);
    }

    public void initialize(@NonNull String webViewUrl) {
        if (TextUtils.isEmpty(webViewUrl)) {
            throw new IllegalArgumentException("WebView url cannot be empty");
        }

        if (!isPlayerReady) {
            initWebView(webViewUrl);
        }
    }

    public void setYouTubeListener(@Nullable YouTubeEventListener listener) {
        this.youTubeListener = listener;
    }

    public void resetTime() {
        duration = null;
        currentTime = null;
        previousState = PlayerStateList.NONE;
    }

    /**
     * Initialises YoutubeWebView with given videoId and youtubeListener
     */
    @SuppressLint("SetJavaScriptEnabled")
    private void initWebView(String webViewUrl) {
        WebSettings set = this.getSettings();
        set.setJavaScriptEnabled(true);
        set.setUseWideViewPort(true);
        set.setLoadWithOverviewMode(true);
        set.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NORMAL);
        set.setCacheMode(WebSettings.LOAD_DEFAULT);
        set.setPluginState(WebSettings.PluginState.ON_DEMAND);
        set.setAllowContentAccess(true);
        set.setAllowFileAccess(false);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            set.setMediaPlaybackRequiresUserGesture(false);
        }
        this.setLayerType(View.LAYER_TYPE_NONE, null);
        this.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        this.loadUrl(webViewUrl);

        if (BuildConfig.DEBUG && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            setWebContentsDebuggingEnabled(true);
        }

        this.setWebViewClient(initWebViewClient());
    }

    @NonNull
    private WebViewClient initWebViewClient() {
        return new WebViewClient() {
            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                return shouldOverrideUrlLoading(request.getUrl());
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (!TextUtils.isEmpty(url)) {
                    Uri uri = Uri.parse(url);
                    return shouldOverrideUrlLoading(uri);
                } else {
                    return false;
                }
            }

            private boolean shouldOverrideUrlLoading(@NonNull Uri url) {
                if (SCHEME.equals(url.getScheme())) {
                    String methodName = url.getHost();
                    String data = url.getQueryParameter(DATA_QUERY_PARAM);
                    String paramCurrentTime = url.getQueryParameter(CURRENT_TIME_PARAM);
                    String eventCallBack = url.getQueryParameter(EVENT_CALLBACK);

                    if (!TextUtils.isEmpty(eventCallBack)) {
                        sendAck(eventCallBack, methodName);
                    }
                    if (!TextUtils.isEmpty(paramCurrentTime)) {
                        currentTime(paramCurrentTime);
                    }
                    if (!TextUtils.isEmpty(methodName)) {
                        invokeNativeMethod(methodName, data);
                    }
                }
                return true; // return true in all case as webView shouldn't allow any other url to open.
            }
        };
    }

    @Override
    public void onScreenStateChanged(int screenState) {
        if (screenState == SCREEN_STATE_OFF) {
            stopPlayer();
        }
    }

    private void invokeNativeMethod(@NonNull String methodName, String args) {
        switch (methodName) {
            case "onReady":
                onReady(args);
                break;
            case "onStateChange":
                onStateChange(args);
                break;
            case "onPlaybackQualityChange":
                onPlaybackQualityChange(args);
                break;
            case "onPlaybackRateChange":
                onPlaybackRateChange(args);
                break;
            case "onError":
                onError(args);
                break;
            case "onApiChange":
                onApiChange(args);
                break;
            case "currentTime":
                currentTime(args);
                break;
            case "duration":
                duration(args);
                break;
            case "logs":
                logs(args);
                break;
            case "onYouTubeIframeAPIFailedToLoad":
                onYouTubeIframeAPIFailedToLoad(args);
                break;
            case "onYouTubeIframeAPIReady":
                onYouTubeIframeAPIReady(args);
                break;
            default:
                break;
        }
    }

    /**
     * APP TO WEB API's
     */
    @SuppressWarnings("unused")
    public void seekToMillis(double mil) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "seekToMillis : ");
        }
        this.loadUrl("javascript:onSeekTo(" + mil + ")");
    }

    @SuppressWarnings("unused")
    public void pause() {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "pause");
        }
        this.loadUrl("javascript:onVideoPause()");
    }

    public void stop() {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "stop");
        }
        if (youTubeListener != null) {
            youTubeListener.onStop(getTimeInMilliSec(currentTime), getTimeInMilliSec(duration));
        }
        this.loadUrl("javascript:onVideoStop()");
    }

    public void setDuration() {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "setDuration");
        }
        this.loadUrl("javascript:sendDuration()");
    }

    @SuppressWarnings("unused")
    public void play() {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "play");
        }
        this.loadUrl("javascript:onVideoPlay()");
    }

    public void loadVideo(String videoId) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "loadVideo : " + videoId);
        }
        this.loadUrl("javascript:loadVideo('" + videoId + "')");
    }

    @SuppressWarnings("unused")
    public void cueVideo(String videoId) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "cueVideo : " + videoId);
        }
        this.loadUrl("javascript:cueVideo('" + videoId + "')");
    }

    private void sendAck(String callBack, String methodName) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "sendAck for :" + methodName);
        }
        this.loadUrl("javascript:" + callBack);
    }

    //It will make player ready for next video being played
    public void onReadyPlayer() {
        if (youTubeListener != null && isPlayerReady) {
            youTubeListener.onReady();
        }
    }

    /**
     * WEB TO APP
     */
    private void onReady(@NonNull String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "onReady(" + arg + ")");
        }

        isPlayerReady = true;
        if (youTubeListener != null) {
            youTubeListener.onReady();
        }
    }

    private void onStateChange(String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "onStateChange(" + arg + ")");
        }
        previousState = arg;
        if (youTubeListener != null) {
            //noinspection StatementWithEmptyBody
            if (PlayerStateList.NOT_STARTED.equalsIgnoreCase(arg)) {
                //handle when needed.
            } else if (PlayerStateList.ENDED.equalsIgnoreCase(arg)) {
                youTubeListener.onStop(getTimeInMilliSec(currentTime), getTimeInMilliSec(duration));
            } else if (PlayerStateList.PLAYING.equalsIgnoreCase(arg)) {
                if (TextUtils.isEmpty(duration)) {
                    setDuration();
                }
                youTubeListener.onPlay(getTimeInMilliSec(currentTime));
            } else if (PlayerStateList.PAUSED.equalsIgnoreCase(arg)) {
                youTubeListener.onPause(getTimeInMilliSec(currentTime));
            } else if (PlayerStateList.BUFFERING.equalsIgnoreCase(arg)) {
                youTubeListener.onBuffering(getTimeInMilliSec(currentTime), true);
            } else if (PlayerStateList.CUED.equalsIgnoreCase(arg)) {
                youTubeListener.onCued();
            }
        }
    }

    private void onPlaybackQualityChange(String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "onPlaybackQualityChange(" + arg + ")");
        }
    }

    private void onPlaybackRateChange(String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "onPlaybackRateChange(" + arg + ")");
        }
    }

    private void onError(String arg) {
        if (BuildConfig.DEBUG) {
            Log.e(TAG, "onError(" + arg + ")");
        }
        if (youTubeListener != null) {
            youTubeListener.onInitializationFailure(arg);
        }
    }

    private void onApiChange(String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "onApiChange(" + arg + ")");
        }
    }

    private void duration(String seconds) {
        if (!TextUtils.isEmpty(seconds) && !"UNDEFINED".equalsIgnoreCase(seconds)) {
            duration = seconds;
        }
    }

    private void currentTime(String seconds) {
        if (!TextUtils.isEmpty(seconds)) {
            currentTime = seconds;
        }
    }

    private void logs(String arg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "logs(" + arg + ")");
        }
    }

    private void onYouTubeIframeAPIFailedToLoad(String args) {
        if (youTubeListener != null) {
            youTubeListener.onInitializationFailure(args);
        }
    }

    @SuppressWarnings("unused")
    private void onYouTubeIframeAPIReady(String args) {
        //intentionally empty
    }

    private int getTimeInMilliSec(String seconds) {
        double time = 0.0;
        if (!TextUtils.isEmpty(seconds)) {
            try {
                time = Double.parseDouble(seconds) * MULTIPLIER;
            } catch (NumberFormatException ignored) {
                Log.e(TAG, ignored.getMessage());
            }
        }
        return (int) time;
    }

    public void stopPlayer() {
        if (isPlayerReady
                && (PlayerStateList.PLAYING.equals(previousState)
                || PlayerStateList.BUFFERING.equals(previousState)
                || PlayerStateList.PAUSED.equals(previousState)
                || PlayerStateList.CUED.equals(previousState))) {
            stop();
        }
    }
}
