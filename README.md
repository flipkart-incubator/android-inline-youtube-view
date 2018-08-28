# inline-youtube-view 

[![](https://jitpack.io/v/flipkart-incubator/inline-youtube-view.svg)](https://jitpack.io/#flipkart-incubator/android-inline-youtube-view) [![Build Status](https://travis-ci.org/flipkart-incubator/android-inline-youtube-view.svg?branch=master)](https://travis-ci.org/flipkart-incubator/android-inline-youtube-view) 

YouTube component for Android, iOS and React. This is a suite of utility libraries around using YouTube inside your [Android](https://github.com/flipkart-incubator/inline-youtube-view/), [iOS](https://github.com/flipkart-incubator/ios-inline-youtube-view/) or React Native app.

# youtube-android

Playing Youtube on Android (specially inline) comes with some challenges :  
   - YouTube SDK does not work on all devices ( where YouTube services could have been uninstalled)
   - You cannot run more than one instance of the YouTube view
   - Playing them inline where in a list you can have more than one videos in a single list. 
   
inline-youtube-view for Android checks if the services are available and will fall back gracefully to using WebView in the event they are not. 

YouTubePlayerView : The YouTubePlayerView provided by the YouTube SDK comes with a restriction that the activty hosting this needs to extend from YouTubeBaseActivity. This view removes these restrictions. 

## Demo Gifs

### YouTubePlayer in Activity (Fullscreen Mode)

![YouTube Activity](https://github.com/flipkart-incubator/inline-youtube-view/blob/master/youtube-activity-android.gif)

### YouTubePlayer in Fragment (inline native)

![YouTube Fragment](https://github.com/flipkart-incubator/inline-youtube-view/blob/master/youtube-fragment-android.gif)

## How to use ?

Add it in your root build.gradle at the end of repositories :

````java
allprojects {
   repositories {
     ...
     maven { url "https://jitpack.io" }
   }
}
````

Add the dependency

````java
dependencies {
    implementation 'com.github.flipkart-incubator:android-inline-youtube-view:1.0.3'
}
````

### YouTubePlayer Activity

Start an YouTubeActivity intent with apiKey and videoId. This will play the youtube video in a new activity in fullscreen mode.

````java
Intent intent = new Intent(MainActivity.this, YouTubeActivity.class);
intent.putExtra("apiKey", Constants.API_KEY);
intent.putExtra("videoId", "3AtDnEC4zak");
startActivity(intent);
````

Also, make sure that you add the activity in the AndroidManifest.xml file.

````java
<activity android:name="com.flipkart.youtubeview.activity.YouTubeActivity" />
````

### YouTubePlayer Inline

Create an instance of YouTubePlayerView inside a fragment. To initialize the player, you need to call the initPlayer method with following params:
1. apiKey
2. videoId
3. webviewUrl : the link to iframe.html file (this is required when the device is not able to render native video, a fallback). By default, use 'https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html'
4. playerType : native, webview or auto (try native, else fallback to webview)
5. listener : callback listener
6. fragment : fragment hosting this view
7. imageLoader : to load thumbnail image

````java
YouTubePlayerView playerView = new YouTubePlayerView(context);
playerView.initPlayer(Constants.API_KEY, videoId, "https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html", playerType, listener, fragment, imageLoader);

````

## YouTube iOS Player

We have open-sourced the inline-youtube-player for [iOS](https://github.com/flipkart-incubator/ios-inline-youtube-view) also.

## Contributing

The easiest way to contribute is by [forking the repo](https://help.github.com/articles/fork-a-repo/), making your changes and [creating a pull request](https://help.github.com/articles/creating-a-pull-request/).
