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
package com.flipkart.youtubeview;

import android.content.Context;
import android.graphics.PorterDuff;
import android.os.Build;
import android.support.annotation.MainThread;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.flipkart.youtubeview.fragment.YouTubeBaseFragment;
import com.flipkart.youtubeview.fragment.YouTubeFragment;
import com.flipkart.youtubeview.fragment.YouTubeWebViewFragment;
import com.flipkart.youtubeview.listener.YouTubeEventListener;
import com.flipkart.youtubeview.models.ImageLoader;
import com.flipkart.youtubeview.models.YouTubePlayerType;
import com.flipkart.youtubeview.util.ServiceUtil;

public class YouTubePlayerView extends FrameLayout {

    public static final String TAG = "YouTubeFragmentTAG";
    private static final double ASPECT_RATIO = 0.5625; //aspect ratio of player 9:16(height/width)

    protected ImageView playIcon;
    @YouTubePlayerType
    private int playerType;

    private String videoId;
    @Nullable
    private YouTubeEventListener listener;
    private Fragment fragment;

    private String key;
    private FrameLayout playerContainer;
    private ImageView thumbnailImageView;
    private String webViewUrl;
    private ImageLoader imageLoader;

    public YouTubePlayerView(Context context) {
        super(context);
        init(context);
    }

    public YouTubePlayerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public YouTubePlayerView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int newWidth;
        int newHeight;
        newWidth = getMeasuredWidth();
        newHeight = (int) (newWidth * ASPECT_RATIO);
        setMeasuredDimension(newWidth, newHeight);
        if (playerContainer != null && playerContainer.getMeasuredHeight() != newHeight) {
            ViewGroup.LayoutParams layoutParams = playerContainer.getLayoutParams();
            layoutParams.height = newHeight;
            playerContainer.setLayoutParams(layoutParams);

            String url = "https://img.youtube.com/vi/" + videoId + "/0.jpg";
            if (null != imageLoader) {
                imageLoader.loadImage(thumbnailImageView, url, getMeasuredHeight(), getMeasuredWidth());
            }
        }
    }

    @MainThread
    public void initPlayer(@NonNull String apiKey, @NonNull String videoId, @Nullable String webViewUrl, @YouTubePlayerType int playerType,
                           @Nullable YouTubeEventListener listener, @NonNull Fragment fragment, @NonNull ImageLoader imageLoader) {
        if (TextUtils.isEmpty(videoId) || TextUtils.isEmpty(apiKey)) {
            throw new IllegalArgumentException("Video Id or key cannot be null");
        }

        //noinspection ConstantConditions
        if (fragment == null) {
            throw new IllegalArgumentException("Fragment cannot be null");
        }

        //noinspection ConstantConditions
        if (imageLoader == null) {
            throw new IllegalArgumentException("ImageLoader cannot be null");
        }

        this.key = apiKey;
        this.videoId = videoId;
        this.webViewUrl = webViewUrl;
        this.playerType = playerType;
        this.listener = listener;
        this.fragment = fragment;
        this.imageLoader = imageLoader;
    }

    private void init(@NonNull Context context) {
        LayoutInflater inflater = LayoutInflater.from(context);
        View itemView = inflater.inflate(R.layout.video_container, this, false);
        this.addView(itemView);
        playerContainer = itemView.findViewById(R.id.youtubeFragmentContainer);
        playerContainer.setId(0);
        thumbnailImageView = itemView.findViewById(R.id.video_thumbnail_image);
        playIcon = itemView.findViewById(R.id.play_btn);

        ProgressBar progressBar = itemView.findViewById(R.id.recycler_progressbar);
        // For else case there is a layout defined for v21 and above
        if (progressBar != null && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            int color;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                color = context.getResources().getColor(R.color.default_progress_bar_color, null);
            } else {
                color = context.getResources().getColor(R.color.default_progress_bar_color);
            }
            progressBar.getIndeterminateDrawable().setColorFilter(color, PorterDuff.Mode.MULTIPLY);
        }

        setListeners();
    }

    private void setListeners() {
        OnClickListener onClickListener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                handleBindPlayer();
            }
        };

        thumbnailImageView.setOnClickListener(onClickListener);
        playIcon.setOnClickListener(onClickListener);
    }

    private void handleBindPlayer() {
        switch (playerType) {
            case YouTubePlayerType.WEB_VIEW:
                attachPlayer(false);
                break;
            case YouTubePlayerType.STRICT_NATIVE:
                bindPlayer(false);
                break;
            case YouTubePlayerType.AUTO:
            case YouTubePlayerType.INVALID_VIEW:
            default:
                bindPlayer(true);
                break;
        }
    }

    private void bindPlayer(boolean auto) {
        if (!ServiceUtil.isYouTubeServiceAvailable(getContext())) {
            if (!auto && listener != null) {
                listener.onNativeNotSupported();
            } else {
                attachPlayer(false);
            }
        } else {
            attachPlayer(true);
        }
    }

    private void attachPlayer(boolean isNative) {
        if (playerContainer.getId() != R.id.youtubeFragmentContainer) {
            YouTubeBaseFragment currentYouTubeFragment = removeCurrentYouTubeFragment();
            playerContainer.setId(R.id.youtubeFragmentContainer);
            YouTubeBaseFragment youtubePlayerFragment;
            if (isNative) {
                youtubePlayerFragment = YouTubeFragment.newInstance(key, videoId);
            } else {
                YouTubeWebViewFragment webViewFragment = YouTubeWebViewFragment.newInstance(webViewUrl, videoId);
                if (currentYouTubeFragment instanceof YouTubeWebViewFragment) {
                    webViewFragment.setWebView(((YouTubeWebViewFragment) currentYouTubeFragment).removeWebView());
                }
                youtubePlayerFragment = webViewFragment;
            }

            youtubePlayerFragment.setYouTubeEventListener(listener);

            this.fragment.getChildFragmentManager().beginTransaction().add(R.id.youtubeFragmentContainer, (Fragment) youtubePlayerFragment, TAG)
                    .setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out)
                    .commit();
        }
    }

    private YouTubeBaseFragment removeCurrentYouTubeFragment() {
        FragmentManager fragmentManager = fragment.getChildFragmentManager();
        Fragment youTubeFragment = fragmentManager.findFragmentByTag(TAG);
        YouTubeBaseFragment youTubeBaseFragment = null;
        if (youTubeFragment instanceof YouTubeBaseFragment) {
            youTubeBaseFragment = (YouTubeBaseFragment) youTubeFragment;
            View fragmentView = youTubeFragment.getView();
            ViewParent parentView = null != fragmentView ? fragmentView.getParent() : null;
            youTubeBaseFragment.release();
            fragmentManager.beginTransaction().remove(youTubeFragment).commitAllowingStateLoss();
            fragmentManager.executePendingTransactions();
            if (parentView instanceof View && ((View) parentView).getId() == R.id.youtubeFragmentContainer) {
                ((View) parentView).setId(0);
            }
        }
        return youTubeBaseFragment;
    }

    public void unbindPlayer() {
        if (playerContainer.getId() == R.id.youtubeFragmentContainer) {
            removeCurrentYouTubeFragment();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        unbindPlayer();
        super.onDetachedFromWindow();
    }
}
