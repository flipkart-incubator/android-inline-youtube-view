package com.flipkart.youtubeview.models;

import android.support.annotation.NonNull;
import android.widget.ImageView;

public interface ImageLoader {
    /**
     * Callback to load image (thumbnail view)
     *
     * @param imageView imageview
     * @param url       url of image
     * @param height    height
     * @param width     width
     */
    void loadImage(@NonNull ImageView imageView, @NonNull String url, int height, int width);
}
