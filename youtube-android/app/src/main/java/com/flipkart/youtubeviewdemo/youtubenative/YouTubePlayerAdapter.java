package com.flipkart.youtubeviewdemo.youtubenative;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.flipkart.youtubeview.YouTubePlayerView;
import com.flipkart.youtubeview.models.ImageLoader;
import com.flipkart.youtubeviewdemo.R;
import com.flipkart.youtubeviewdemo.helper.Constants;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

public class YouTubePlayerAdapter extends RecyclerView.Adapter<YouTubePlayerAdapter.YouTubePlayerViewHolder> {

    private ArrayList<String> videoIds;
    private Context context;
    private Fragment fragment;
    private int playerType;

    private ImageLoader imageLoader = new ImageLoader() {
        @Override
        public void loadImage(@NonNull ImageView imageView, @NonNull String url, int height, int width) {
            Picasso.with(imageView.getContext()).load(url).resize(width, height).centerCrop().into(imageView);
        }
    };

    public YouTubePlayerAdapter(Context context, ArrayList<String> contents, Fragment fragment, int playerType) {
        this.context = context;
        this.videoIds = contents;
        this.fragment = fragment;
        this.playerType = playerType;
    }

    @Override
    public int getItemCount() {
        return videoIds.size();
    }

    @Override
    public YouTubePlayerViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.youtube_player, parent, false);
        return new YouTubePlayerViewHolder(view);
    }

    @Override
    public int getItemViewType(int position) {
        return position;
    }

    @Override
    public void onBindViewHolder(final YouTubePlayerViewHolder holder, int position) {
        YouTubePlayerView playerView = holder.playerView;
        String videoId = videoIds.get(position);

        playerView.initPlayer(Constants.API_KEY, videoId, "https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html", playerType, null, fragment, imageLoader);
    }

    public static class YouTubePlayerViewHolder extends RecyclerView.ViewHolder {
        public YouTubePlayerView playerView;

        public YouTubePlayerViewHolder(View view) {
            super(view);
            playerView = view.findViewById(R.id.youtube_player_view);
        }
    }
}
