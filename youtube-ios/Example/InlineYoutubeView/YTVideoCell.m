//
//  YTVideoView.m
//  InlineYoutubeView_Example
//
//  Created by SHUBHANKAR YASH on 31/01/18.
//  Copyright 2018 Flipkart Internet Pvt. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "YTVideoCell.h"

//The url where the HTML is hosted
NSString *const HTML_URL = @"https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html";
NSString *const PLAY_ICON = @"playIcon";

//Dimension of the play icon used over the thumbnail
CGFloat const PLAY_ICON_DIMENSION = 48;


@interface YTVideoCell ()
    @end

@implementation YTVideoCell
    
-(id)initWithFrame:(CGRect)frame andVideoId: (NSString *)videoId andShouldPlayInline: (BOOL) playInline {
    self = [super initWithFrame:frame];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Assigning the video properties
    self.videoId = videoId;
    self.playInline = playInline;
    
    [self setupThumbnailWithFrame:frame];
    return self;
}
    
    
-(void) setupThumbnailWithFrame: (CGRect)frame {
    self.thumbnailView = [[UIImageView alloc] initWithFrame:frame];
    self.thumbnailView.contentMode = UIViewContentModeScaleToFill;
    [self superImposePlayIconOnThumbnail];
    [self asynchronouslyDownloadThumbnailImage];
}
    
    
-(void) superImposePlayIconOnThumbnail {
    //Setup the playIconView and place it on top of the thumbnail image
    UIImage *playIconImage = [UIImage imageNamed:PLAY_ICON];
    self.playIconView = [[UIImageView alloc] initWithImage:playIconImage];
    [self.playIconView setFrame:CGRectMake(self.thumbnailView.bounds.size.width/2 - PLAY_ICON_DIMENSION/2, self.thumbnailView.bounds.size.height/2 - PLAY_ICON_DIMENSION/2, PLAY_ICON_DIMENSION, PLAY_ICON_DIMENSION)];
    [self.thumbnailView addSubview:self.playIconView];
    [self addSubview:self.thumbnailView];
}
    
    
-(void)asynchronouslyDownloadThumbnailImage {
    NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/hqdefault.jpg", _videoId];
    NSURL *thumbnailUrl = [[NSURL alloc] initWithString:urlString];
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
        NSData * data = [[NSData alloc] initWithContentsOfURL:thumbnailUrl];
        UIImage * image = [[UIImage alloc] initWithData:data];
        dispatch_async( dispatch_get_main_queue(), ^(void){
            if(image != nil)
            {
                [self.thumbnailView setImage:image];
            }
        });
    });
}
    
    
-(void) playButtonClicked {
    [self.playIconView removeFromSuperview];
    
    [self addLoaderOverThumbnail];
    [self setupYoutubeView];
    
    //Wait for youtube player to to get ready or proceed if it is ready
    if([self.youtubeView loadYTIframe]) {
        [self playerViewDidBecomeReady:self.youtubeView];
    }
}
    
-(void)addLoaderOverThumbnail {
    self.loaderView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loaderView setFrame:CGRectMake(self.thumbnailView.bounds.size.width/2 - PLAY_ICON_DIMENSION/2, self.thumbnailView.bounds.size.height/2 - PLAY_ICON_DIMENSION/2, PLAY_ICON_DIMENSION, PLAY_ICON_DIMENSION)];
    [self.loaderView startAnimating];
    [self.thumbnailView addSubview:self.loaderView];
}
    
-(void)setupYoutubeView {
    if(_playInline) {
        self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:kYTPlayerModeInline];
    } else {
        self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:kYTPlayerModeFullScreen];
    }
    
    self.youtubeView.frame = self.thumbnailView.frame;
    self.youtubeView.delegate = self;
}
    
/*
 InlineYoutubeView callbacks
 */
- (void)playerViewDidBecomeReady:(nonnull InlineYoutubeView *)playerView {
    [self removeLoaderFromThumbnail];
    [self loadVideo:playerView];
}
    
-(void) removeLoaderFromThumbnail {
    [self.loaderView stopAnimating];
    [self.loaderView removeFromSuperview];
}
    
-(void) loadVideo: (nonnull InlineYoutubeView *)playerView {
    [self addSubview:playerView];
    [playerView loadVideoById:_videoId startSeconds:0 suggestedQuality:kYTPlaybackQualityAuto];
    [playerView playVideo];
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateUnknown:
        NSLog(@"Unknown state");
        break;
        case kYTPlayerStateUnstarted:
        NSLog(@"Video Unstarted");
        break;
        case kYTPlayerStateQueued:
        NSLog(@"Video Queued");
        break;
        case kYTPlayerStateBuffering:
        NSLog(@"Video buffering");
        break;
        case kYTPlayerStatePlaying:
        NSLog(@"Video started playing");
        break;
        case kYTPlayerStatePaused:
        NSLog(@"Video paused");
        break;
        case kYTPlayerStateEnded:
        NSLog(@"Video ended");
        break;
    }
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    NSLog(@"Quality changed");
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView receivedError:(YTPlayerError)error {
    NSLog(@"Received error");
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didPlayTime:(float)playTime {
    
    //Getting the duration through a completion block
    [playerView getDuration:^(NSTimeInterval duration, NSError * _Nullable error) {
        NSLog(@"currentTime %f", playTime);
        NSLog(@"totalDuration %f", duration);
    }];
}
    
    @end

