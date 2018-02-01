//
//  YTVideoView.m
//  InlineYoutubeView_Example
//
//  Created by SHUBHANKAR YASH on 31/01/18.
//  Copyright © 2018 shubhankaryash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTVideoCell.h"

NSString *const INLINE = @"INLINE";
NSString *const FULLSCREEN = @"FULLSCREEN";

NSString *const HTML_URL = @"https://cdn.rawgit.com/flipkart-incubator/inline-youtube-view/60bae1a1/youtube-android/youtube_iframe_player.html";
NSString *const PLAY_ICON = @"playIcon";

CGFloat const PLAY_ICON_DIMENSION = 48;


@interface YTVideoCell ()
    @end

@implementation YTVideoCell
    
-(id)initWithFrame:(CGRect)frame andVideoId: (NSString *)videoId andShouldPlayInline: (BOOL) playInline {
    self = [super initWithFrame:frame];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.videoId = videoId;
    self.playInline = playInline;
    
    self.thumbnailView = [[UIImageView alloc] initWithFrame:frame];
    self.thumbnailView.contentMode = UIViewContentModeScaleToFill;
    
    UIImage *playIconImage = [UIImage imageNamed:PLAY_ICON];
    self.playIconView = [[UIImageView alloc] initWithImage:playIconImage];
    [self.playIconView setFrame:CGRectMake(self.thumbnailView.bounds.size.width/2 - PLAY_ICON_DIMENSION/2, self.thumbnailView.bounds.size.height/2 - PLAY_ICON_DIMENSION/2, PLAY_ICON_DIMENSION, PLAY_ICON_DIMENSION)];
    [self.thumbnailView addSubview:self.playIconView];

    [self addSubview:self.thumbnailView];
    
    NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/hqdefault.jpg", videoId];
    NSURL *thumbnailUrl = [[NSURL alloc] initWithString:urlString];
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                   {
                       NSData * data = [[NSData alloc] initWithContentsOfURL:thumbnailUrl];
                       UIImage * image = [[UIImage alloc] initWithData:data];
                       dispatch_async( dispatch_get_main_queue(), ^(void){
                           if(image != nil)
                           {
                               [self.thumbnailView setImage:image];
                           }
                       });
                   });
    return self;
}

    
-(void) playButtonClicked {
    [self.playIconView removeFromSuperview];
    self.loaderView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loaderView setFrame:CGRectMake(self.thumbnailView.bounds.size.width/2 - PLAY_ICON_DIMENSION/2, self.thumbnailView.bounds.size.height/2 - PLAY_ICON_DIMENSION/2, PLAY_ICON_DIMENSION, PLAY_ICON_DIMENSION)];
    [self.loaderView startAnimating];
    [self.thumbnailView addSubview:self.loaderView];
    
    if(_playInline) {
        self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:INLINE];
    } else {
        self.youtubeView = [[InlineYoutubeView alloc] initWithHtmlUrl:HTML_URL andVideoPlayerMode:FULLSCREEN];
    }
    
    self.youtubeView.frame = self.bounds;
    self.youtubeView.delegate = self;
    
    if([self.youtubeView loadYTIframe]) {
        [self playerViewDidBecomeReady:self.youtubeView];
    }
}
    
- (void)playerViewDidBecomeReady:(nonnull InlineYoutubeView *)playerView {
    [self.loaderView stopAnimating];
    [self.loaderView removeFromSuperview];
    [self addSubview:playerView];
    
    [playerView loadVideoById:_videoId startSeconds:0 suggestedQuality:kYTPlaybackQualityAuto];
    [playerView playVideo];
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToState:(YTPlayerState)state {
    
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView receivedError:(YTPlayerError)error {
    
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView didPlayTime:(float)playTime {
    
}
    
- (void)playerView:(nonnull InlineYoutubeView *)playerView duration:(NSTimeInterval)duration {
    
}

    
    
    @end
