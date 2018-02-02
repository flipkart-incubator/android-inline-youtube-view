# InlineYoutubeView

[![CI Status](http://img.shields.io/travis/shubhankaryash/InlineYoutubeView.svg?style=flat)](https://travis-ci.org/shubhankaryash/InlineYoutubeView)
[![Version](https://img.shields.io/cocoapods/v/InlineYoutubeView.svg?style=flat)](http://cocoapods.org/pods/InlineYoutubeView)
[![License](https://img.shields.io/cocoapods/l/InlineYoutubeView.svg?style=flat)](http://cocoapods.org/pods/InlineYoutubeView)
[![Platform](https://img.shields.io/cocoapods/p/InlineYoutubeView.svg?style=flat)](http://cocoapods.org/pods/InlineYoutubeView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

InlineYoutubeView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'InlineYoutubeView'
```

## Usage

Import the header file
```objective-c
#import <InlineYoutubeView/InlineYoutubeView.h>
```

Create an object of the InlineYoutubeView
```objective-c
@property (nonatomic, strong) InlineYoutubeView *youtubeView;
```
Initialise the Inline youtube view
```objective-c
NSString *const INLINE = @"INLINE";
NSString *const FULLSCREEN = @"FULLSCREEN";

//The url where the HTML is hosted. You can have any custom HTML url as well. So you can modify the iframe provided, upload the modified HTML file and use the url here
NSString *const HTML_URL = @"https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html";

//Incase you need your youtube view to open inline
self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:INLINE];

//Incase you need your youtube view to open in fullscreen
self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:FULLSCREEN];
```
Set the delegate of the youtube view to self. This will ensure that you start receiving all the InlineYoutubeView callbacks
```objective-c
self.youtubeView.delegate = self;
```

Load the iframe. If it is not loaded right now, the InlineYoutubeView will give a playerViewDidBecomeReady callback when it loads up. If it is loaded we will simply call the method right now to start up the video
```objective-c
//Wait for youtube player to to get ready or proceed if it is ready.
if([self.youtubeView loadYTIframe]) {
[self playerViewDidBecomeReady:self.youtubeView];
}
```

Implement the playerViewDidBecomeReady method of the InlineYoutubeViewDelegate. This method should be called when your player becomes ready.
```objective-c
- (void)playerViewDidBecomeReady:(nonnull InlineYoutubeView *)playerView {
//Load the youtube video with the videoId of the video
[playerView loadVideoById:_videoId startSeconds:0 suggestedQuality:kYTPlaybackQualityAuto];
[playerView playVideo];}
```

You can implement other methods of the InlineYoutubeViewDelegate depending on your requirements. Check out the InlineYoutubeView.h file for more documentation on the same.
```objective-c
- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToState:(YTPlayerState)state;

- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToQuality:(YTPlaybackQuality)quality;

- (void)playerView:(nonnull InlineYoutubeView *)playerView receivedError:(YTPlayerError)error ;

- (void)playerView:(nonnull InlineYoutubeView *)playerView didPlayTime:(float)playTime ;

- (void)playerView:(nonnull InlineYoutubeView *)playerView duration:(NSTimeInterval)duration ;

- (nonnull UIColor *)playerViewPreferredWebViewBackgroundColor:(nonnull InlineYoutubeView *)playerView;

- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull InlineYoutubeView *)playerView;
```
## Author

shubhankaryash, shubhankar.yash@flipkart.com

## License

InlineYoutubeView is available under the Apache 2.0 license. See the LICENSE file for more info.
