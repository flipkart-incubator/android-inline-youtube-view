package com.flipkart.youtubeviewdemo.youtubenative;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;

import com.flipkart.youtubeviewdemo.R;

public class YouTubeNativeActivityDemo extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.youtube_native_activity_demo);

        Bundle extras = getIntent().getExtras();

        YouTubeNativeFragmentDemo youTubeNativeFragmentDemo = new YouTubeNativeFragmentDemo();
        youTubeNativeFragmentDemo.setArguments(extras);
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        fragmentTransaction.replace(R.id.container, youTubeNativeFragmentDemo);
        fragmentTransaction.commit();
    }
}
