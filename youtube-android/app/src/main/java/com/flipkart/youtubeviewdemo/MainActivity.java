package com.flipkart.youtubeviewdemo;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;

import com.flipkart.youtubeview.activity.YouTubeActivity;
import com.flipkart.youtubeview.models.YouTubePlayerType;
import com.flipkart.youtubeviewdemo.helper.Constants;
import com.flipkart.youtubeviewdemo.youtubenative.YouTubeNativeActivityDemo;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button singleYoutubePlayerButton = (Button) findViewById(R.id.singleYoutubePlayer);
        Button youtubeNativeFragmentButton = (Button) findViewById(R.id.youtubeNativeFragment);
        Button youtubeWebViewFragmentButton = (Button) findViewById(R.id.youtubeWebviewFragment);
        final RelativeLayout container = (RelativeLayout) findViewById(R.id.container);

        singleYoutubePlayerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, YouTubeActivity.class);
                intent.putExtra("apiKey", Constants.API_KEY);
                intent.putExtra("videoId", "3AtDnEC4zak");
                startActivity(intent);
            }
        });

        youtubeNativeFragmentButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, YouTubeNativeActivityDemo.class);
                intent.putExtra("playerType", YouTubePlayerType.STRICT_NATIVE);
                startActivity(intent);
            }
        });

        youtubeWebViewFragmentButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, YouTubeNativeActivityDemo.class);
                intent.putExtra("playerType", YouTubePlayerType.WEB_VIEW);
                startActivity(intent);
            }
        });
    }
}
