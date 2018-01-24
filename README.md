# inline-youtube-view

YouTube component for Android, iOS and React. This is a suite of utility libraries around using YouTube inside your Android, iOS or React Native app.

# youtube-android

Playing Youtube on Android (specially inline) comes with some challenges :  
   - YouTube SDK does not work on all devices ( where YouTube services could have been uninstalled)
   - You cannot run more than one instance of the YouTube view
   - Playing them inline where in a list you can have more than one videos in a single list. 
   
inline-youtube-view for Android checks if the services are available and will fall back gracefully to using WebView in the event they are not. 

YouTubePlayerView : The YouTubePlayerView provided by the YouTube SDK comes with a restriction that the activty hosting this needs to extend from YouTubeBaseActivity. This view removes these restrictions. 

### Screenshots

YouTube Activity (Fullscreen Mode)

![YouTube Activity](https://github.com/flipkart-incubator/inline-youtube-view/blob/master/youtube-activity-android.gif)
