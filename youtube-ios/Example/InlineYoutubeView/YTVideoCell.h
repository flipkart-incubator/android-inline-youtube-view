//
//  YTVideoView.h
//  InlineYoutubeView
//
//  Created by SHUBHANKAR YASH on 31/01/18.
//  Copyright © 2018 shubhankaryash. All rights reserved.
//
@import UIKit;
#import <InlineYoutubeView/InlineYoutubeView.h>

@interface YTVideoCell : UITableViewCell<InlineYoutubeViewDelegate>
    @property (nonatomic, strong) InlineYoutubeView *youtubeView;
    @property (nonatomic, strong) UIImageView *thumbnailView;
    @property (nonatomic, strong) UIImageView *playIconView;
    @property (nonatomic, strong) UIActivityIndicatorView *loaderView;
    @property (nonatomic, strong) NSString *videoId;
    @property (nonatomic, assign) BOOL playInline;
    
    -(id)initWithFrame:(CGRect)frame andVideoId: (NSString *)videoId andShouldPlayInline: (BOOL) playInline;
    -(void) playButtonClicked;
@end
