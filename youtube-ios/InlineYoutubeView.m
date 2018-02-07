// Copyright 2014 Google Inc. All rights reserved.
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

#define NETWORK_OFFLINE_ERROR_CODE -1009
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#import "InlineYoutubeView.h"

// These are instances of NSString because we get them from parsing a URL. It would be silly to
// convert these into an integer just to have to convert the URL query string value into an integer
// as well for the sake of doing a value comparison. A full list of response error codes can be
// found here:
NSString static *const kYTPlayerStateUnknownCode = @"unknown";

NSString static *const kYTPlayerStateUnstartedCode = @"UNSTARTED";
NSString static *const kYTPlayerStateEndedCode = @"ENDED";
NSString static *const kYTPlayerStatePlayingCode = @"PLAYING";
NSString static *const kYTPlayerStatePausedCode = @"PAUSED";
NSString static *const kYTPlayerStateBufferingCode = @"BUFFERING";
NSString static *const kYTPlayerStateCuedCode = @"CUED";

// Constants representing playback quality.
NSString static *const kYTPlaybackQualitySmallQuality = @"small";
NSString static *const kYTPlaybackQualityMediumQuality = @"medium";
NSString static *const kYTPlaybackQualityLargeQuality = @"large";
NSString static *const kYTPlaybackQualityHD720Quality = @"hd720";
NSString static *const kYTPlaybackQualityHD1080Quality = @"hd1080";
NSString static *const kYTPlaybackQualityHighResQuality = @"highres";
NSString static *const kYTPlaybackQualityAutoQuality = @"auto";
NSString static *const kYTPlaybackQualityDefaultQuality = @"default";
NSString static *const kYTPlaybackQualityUnknownQuality = @"unknown";

// Constants representing YouTube player errors.
NSString static *const kYTPlayerErrorInvalidParamErrorCode = @"2";
NSString static *const kYTPlayerErrorHTML5ErrorCode = @"5";
NSString static *const kYTPlayerErrorVideoNotFoundErrorCode = @"100";
NSString static *const kYTPlayerErrorNotEmbeddableErrorCode = @"101";
NSString static *const kYTPlayerErrorCannotFindVideoErrorCode = @"105";
NSString static *const kYTPlayerErrorSameAsNotEmbeddableErrorCode = @"150";

// Constants representing player callbacks.
NSString static *const kYTPlayerCallbackOnReady = @"onReady";
NSString static *const kYTPlayerCallbackOnStateChange = @"onStateChange";
NSString static *const kYTPlayerCallbackOnPlaybackQualityChange = @"onPlaybackQualityChange";
NSString static *const kYTPlayerCallbackOnError = @"onError";
NSString static *const kYTPlayerCallbackOnPlayTime = @"currentTime";
NSString static *const kYTPlayerCallbackOnDuration = @"duration";
NSString static *const kYTPlayerCallbackDataKey = @"data";
NSString static *const kYTPlayerCallbackEventResponseCallbackKey = @"callback";


NSString static *const kYTPlayerCallbackOnYouTubeIframeAPIReady = @"onYouTubeIframeAPIReady";
NSString static *const kYTPlayerCallbackOnYouTubeIframeAPIFailedToLoad = @"onYouTubeIframeAPIFailedToLoad";

NSString static *const kYTPlayerEmbedUrlRegexPattern = @"^http(s)://(www.)youtube.com/embed/(.*)$";
NSString static *const kYTPlayerAdUrlRegexPattern = @"^http(s)://pubads.g.doubleclick.net/pagead/conversion/";
NSString static *const kYTPlayerOAuthRegexPattern = @"^http(s)://accounts.google.com/o/oauth2/(.*)$";
NSString static *const kYTPlayerStaticProxyRegexPattern = @"^https://content.googleapis.com/static/proxy.html(.*)$";
NSString static *const kYTPlayerSyndicationRegexPattern = @"^https://tpc.googlesyndication.com/sodar/(.*).html$";

@interface InlineYoutubeView()
    
    @property (nonatomic, strong) NSURL *originURL;
    @property (nonatomic, weak) UIView *initialLoadingView;
    @property(nonatomic, strong) NSURL *htmlUrl;
    @property(nonatomic, assign) YTPlayerMode videoPlayerMode;
    @property(assign) BOOL isYTPlayerLoaded;
    
    @end

@implementation InlineYoutubeView
    
-(id)initWithHtmlUrl:(NSString *)htmlUrl andVideoPlayerMode:(YTPlayerMode)videoPlayerMode {
    if(self = [super init]) {
        self.htmlUrl=[NSURL URLWithString:htmlUrl];
        self.videoPlayerMode = videoPlayerMode;
    }
    return self;
}
    
- (BOOL)loadWithVideoId:(NSString *)videoId {
    return [self loadWithVideoId:videoId playerVars:nil];
}
    
- (BOOL)loadWithPlaylistId:(NSString *)playlistId {
    return [self loadWithPlaylistId:playlistId playerVars:nil];
}
    
- (BOOL)loadWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
    if (!playerVars) {
        playerVars = @{};
    }
    NSDictionary *playerParams = @{ @"videoId" : videoId, @"playerVars" : playerVars };
    return [self loadWithPlayerParams:playerParams];
}
    
- (BOOL)loadWithPlaylistId:(NSString *)playlistId playerVars:(NSDictionary *)playerVars {
    
    // Mutable copy because we may have been passed an immutable config dictionary.
    NSMutableDictionary *tempPlayerVars = [[NSMutableDictionary alloc] init];
    [tempPlayerVars setValue:@"playlist" forKey:@"listType"];
    [tempPlayerVars setValue:playlistId forKey:@"list"];
    if (playerVars) {
        [tempPlayerVars addEntriesFromDictionary:playerVars];
    }
    
    NSDictionary *playerParams = @{ @"playerVars" : tempPlayerVars };
    return [self loadWithPlayerParams:playerParams];
}
    
#pragma mark - Player methods
    
    
-(void)playVideo{
    [self getStringFromEvaluatingJavaScript:@"onVideoPlay();" completionHandler:nil];
}
    
    
- (void)pauseVideo {
    [self notifyDelegateOfYouTubeCallbackUrl:[NSURL URLWithString:[NSString stringWithFormat:@"ytplayer://onStateChange?data=%@", kYTPlayerStatePausedCode]]];
    [self getStringFromEvaluatingJavaScript:@"onVideoPause();" completionHandler:nil];
}
    
    
    
- (void)stopVideo {
    [self getStringFromEvaluatingJavaScript:@"onVideoStop();" completionHandler:nil];
}
    
    
- (void)seekToSeconds:(float)seekToSeconds allowSeekAhead:(BOOL)allowSeekAhead {
    NSNumber *secondsValue = [NSNumber numberWithFloat:seekToSeconds];
    NSString *allowSeekAheadValue = [self stringForJSBoolean:allowSeekAhead];
    NSString *command = [NSString stringWithFormat:@"onSeekTo(%@);", secondsValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
#pragma mark - Cueing methods
    
- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById('%@', %@, '%@');",
                         videoId, startSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
    
- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
          endSeconds:(float)endSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"loadVideo('%@');",
                         videoId];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});",videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, '%@');",
                         videoURL, startSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, %@, '%@');",
                         videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, '%@');",
                         videoURL, startSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
            endSeconds:(float)endSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, %@, '%@');",
                         videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
#pragma mark - Cueing methods for lists
    
- (void)cuePlaylistByPlaylistId:(NSString *)playlistId
                          index:(int)index
                   startSeconds:(float)startSeconds
               suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
    [self cuePlaylist:playlistIdString
                index:index
         startSeconds:startSeconds
     suggestedQuality:suggestedQuality];
}
    
- (void)cuePlaylistByVideos:(NSArray *)videoIds
                      index:(int)index
               startSeconds:(float)startSeconds
           suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    [self cuePlaylist:[self stringFromVideoIdArray:videoIds]
                index:index
         startSeconds:startSeconds
     suggestedQuality:suggestedQuality];
}
    
- (void)loadPlaylistByPlaylistId:(NSString *)playlistId
                           index:(int)index
                    startSeconds:(float)startSeconds
                suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
    [self loadPlaylist:playlistIdString
                 index:index
          startSeconds:startSeconds
      suggestedQuality:suggestedQuality];
}
    
- (void)loadPlaylistByVideos:(NSArray *)videoIds
                       index:(int)index
                startSeconds:(float)startSeconds
            suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    [self loadPlaylist:[self stringFromVideoIdArray:videoIds]
                 index:index
          startSeconds:startSeconds
      suggestedQuality:suggestedQuality];
}
    
#pragma mark - Setting the playback rate
    
- (void)getPlaybackRate:(void (^ __nullable)(float playbackRate, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getPlaybackRate();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(0, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(0, nil);
                    }
                    else {
                        completionHandler([response floatValue], nil);
                    }
                }
            }
        }];
    }
    
    
- (void)setPlaybackRate:(float)suggestedRate {
    NSString *command = [NSString stringWithFormat:@"player.setPlaybackRate(%f);", suggestedRate];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
    
- (void)getAvailablePlaybackRates:(void (^ __nullable)(NSArray * __nullable availablePlaybackRates, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getAvailablePlaybackRates();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(nil, nil);
                    }
                    else {
                        NSData *playbackRateData = [response dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *jsonDeserializationError;
                        NSArray *playbackRates = [NSJSONSerialization JSONObjectWithData:playbackRateData
                                                                                 options:kNilOptions
                                                                                   error:&jsonDeserializationError];
                        if (jsonDeserializationError) {
                            completionHandler(nil, jsonDeserializationError);
                        }
                        completionHandler(playbackRates, nil);
                    }
                }
            }
        }];
    }
#pragma mark - Setting playback behavior for playlists
    
- (void)setLoop:(BOOL)loop {
    NSString *loopPlayListValue = [self stringForJSBoolean:loop];
    NSString *command = [NSString stringWithFormat:@"player.setLoop(%@);", loopPlayListValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
- (void)setShuffle:(BOOL)shuffle {
    NSString *shufflePlayListValue = [self stringForJSBoolean:shuffle];
    NSString *command = [NSString stringWithFormat:@"player.setShuffle(%@);", shufflePlayListValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
#pragma mark - Playback status
    
    
- (void)getVideoLoadedFraction:(void (^ __nullable)(float videoLoadedFraction, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getVideoLoadedFraction();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(0, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(0, nil);
                    }
                    else {
                        completionHandler([response floatValue], nil);
                    }
                }
            }
        }];
    }
    
    
- (void)getCurrentTime:(void (^ __nullable)(float currentTime, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getCurrentTime();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(0, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(0, nil);
                    }
                    else {
                        completionHandler([response floatValue], nil);
                    }
                }
            }
        }];
    }
    
- (void)getDuration:(void (^ __nullable)(NSTimeInterval duration, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getDuration();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(0, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(0, nil);
                    }
                    else {
                        completionHandler([response doubleValue], nil);
                    }
                }
            }
        }];
    }
    
- (void)getPlayerState:(void (^ __nullable)(YTPlayerState playerState, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getPlayerState();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(kYTPlayerStateUnknown, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(kYTPlayerStateUnknown, nil);
                    }
                    else {
                        completionHandler([InlineYoutubeView playerStateForString:response], nil);
                    }
                }
            }
        }];
    }
    
- (void)getPlaybackQuality:(void (^ __nullable)(YTPlaybackQuality playbackQuality, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getPlaybackQuality();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(kYTPlaybackQualityUnknown, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(kYTPlaybackQualityUnknown, nil);
                    }
                    else {
                        completionHandler([InlineYoutubeView playbackQualityForString:response], nil);
                    }
                }
            }
        }];
    }
    
    
- (void)setPlaybackQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.setPlaybackQuality('%@');", qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
#pragma mark - Video information methods
    
    
- (void)getVideoUrl:(void (^ __nullable)(NSURL * __nullable videoUrl, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getVideoUrl();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(nil, nil);
                    }
                    else {
                        completionHandler([NSURL URLWithString:response], nil);
                    }
                }
            }
        }];
    }
    
- (void)getVideoEmbedCode:(void (^ __nullable)(NSString * __nullable videoEmbedCode, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getVideoEmbedCode();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(nil, nil);
                    }
                    else {
                        completionHandler(response, nil);
                    }
                }
            }
        }];
    }
#pragma mark - Playlist methods
    
    
- (void)getPlaylist:(void (^ __nullable)(NSArray * __nullable playlist, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getPlaylist();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(nil, nil);
                    }
                    else {
                        NSData *playlistData = [response dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *jsonDeserializationError;
                        NSArray *videoIds = [NSJSONSerialization JSONObjectWithData:playlistData
                                                                            options:kNilOptions
                                                                              error:&jsonDeserializationError];
                        if (jsonDeserializationError) {
                            completionHandler(nil, jsonDeserializationError);
                        }
                        
                        completionHandler(videoIds, nil);                }
                }
            }
        }];
    }
    
    
- (void)getPlaylistIndex:(void (^ __nullable)(int playlistIndex, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getPlaylistIndex();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(0, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(0, nil);
                    }
                    else {
                        completionHandler([response intValue], nil);
                    }
                }
            }
        }];
    }
    
#pragma mark - Playing a video in a playlist
    
- (void)nextVideo {
    [self getStringFromEvaluatingJavaScript:@"player.nextVideo();" completionHandler:nil];
}
    
- (void)previousVideo {
    [self getStringFromEvaluatingJavaScript:@"player.previousVideo();" completionHandler:nil];
}
    
- (void)playVideoAt:(int)index {
    NSString *command =
    [NSString stringWithFormat:@"player.playVideoAt(%@);", [NSNumber numberWithInt:index]];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
#pragma mark - Helper methods
    
    
- (void)getAvailableQualityLevels:(void (^ __nullable)(NSArray * __nullable availableQualityLevels, NSError * __nullable error))completionHandler
    {
        [self getStringFromEvaluatingJavaScript:@"player.getAvailableQualityLevels().toString();" completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, error);
                } else {
                    if ([response isEqual:[NSNull null]])
                    {
                        completionHandler(nil, nil);
                    }
                    else {
                        NSArray *rawQualityValues = [response componentsSeparatedByString:@","];
                        NSMutableArray *levels = [[NSMutableArray alloc] init];
                        for (NSString *rawQualityValue in rawQualityValues) {
                            YTPlaybackQuality quality = [InlineYoutubeView playbackQualityForString:rawQualityValue];
                            [levels addObject:[NSNumber numberWithInt:quality]];
                        }
                        
                        completionHandler(levels, nil);                }
                }
            }
        }];
    }
    
    
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
    {
        NSURLRequest *request = navigationAction.request;
        
        if ([request.URL.host isEqual: self.originURL.host] || [request.URL.host isEqual: self.htmlUrl.host]){
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        } else if ([request.URL.scheme isEqual:@"ytplayer"]) {
            [self notifyDelegateOfYouTubeCallbackUrl:request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([request.URL.scheme isEqual: @"http"] || [request.URL.scheme isEqual:@"https"]) {
            if([self handleHttpNavigationToUrl:request.URL]) {
                decisionHandler(WKNavigationActionPolicyAllow);
            } else {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            return;
        }
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self giveCallbackForError:error];
}
    
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self giveCallbackForError:error];
}
    
-(void)giveCallbackForError:(NSError *)error {
    if (self.initialLoadingView) {
        [self.initialLoadingView removeFromSuperview];
    }
    if(error.code==NETWORK_OFFLINE_ERROR_CODE){
        [self.delegate playerView:self receivedError:kYTErrorNetworkOffline];
    }
    else{
        [self.delegate playerView:self receivedError:kYTPlayerErrorUnknown];
    }
}
    
    /**
     * Convert a quality value from NSString to the typed enum value.
     *
     * @param qualityString A string representing playback quality. Ex: "small", "medium", "hd1080".
     * @return An enum value representing the playback quality.
     */
+ (YTPlaybackQuality)playbackQualityForString:(NSString *)qualityString {
    YTPlaybackQuality quality = kYTPlaybackQualityUnknown;
    
    if ([qualityString isEqualToString:kYTPlaybackQualitySmallQuality]) {
        quality = kYTPlaybackQualitySmall;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityMediumQuality]) {
        quality = kYTPlaybackQualityMedium;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityLargeQuality]) {
        quality = kYTPlaybackQualityLarge;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityHD720Quality]) {
        quality = kYTPlaybackQualityHD720;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityHD1080Quality]) {
        quality = kYTPlaybackQualityHD1080;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityHighResQuality]) {
        quality = kYTPlaybackQualityHighRes;
    } else if ([qualityString isEqualToString:kYTPlaybackQualityAutoQuality]) {
        quality = kYTPlaybackQualityAuto;
    }
    return quality;
}
    
    /**
     * Convert a |YTPlaybackQuality| value from the typed value to NSString.
     *
     * @param quality A |YTPlaybackQuality| parameter.
     * @return An |NSString| value to be used in the JavaScript bridge.
     */
+ (NSString *)stringForPlaybackQuality:(YTPlaybackQuality)quality {
    switch (quality) {
        case kYTPlaybackQualitySmall:
        return kYTPlaybackQualitySmallQuality;
        case kYTPlaybackQualityMedium:
        return kYTPlaybackQualityMediumQuality;
        case kYTPlaybackQualityLarge:
        return kYTPlaybackQualityLargeQuality;
        case kYTPlaybackQualityHD720:
        return kYTPlaybackQualityHD720Quality;
        case kYTPlaybackQualityHD1080:
        return kYTPlaybackQualityHD1080Quality;
        case kYTPlaybackQualityHighRes:
        return kYTPlaybackQualityHighResQuality;
        case kYTPlaybackQualityAuto:
        return kYTPlaybackQualityAutoQuality;
        default:
        return kYTPlaybackQualityUnknownQuality;
    }
}
    
    /**
     * Convert a state value from NSString to the typed enum value.
     *
     * @param stateString A string representing player state. Ex: "-1", "0", "1".
     * @return An enum value representing the player state.
     */
+ (YTPlayerState)playerStateForString:(NSString *)stateString {
    YTPlayerState state = kYTPlayerStateUnknown;
    if ([stateString isEqualToString:kYTPlayerStateUnstartedCode]) {
        state = kYTPlayerStateUnstarted;
    } else if ([stateString isEqualToString:kYTPlayerStateEndedCode]) {
        state = kYTPlayerStateEnded;
    } else if ([stateString isEqualToString:kYTPlayerStatePlayingCode]) {
        state = kYTPlayerStatePlaying;
    } else if ([stateString isEqualToString:kYTPlayerStatePausedCode]) {
        state = kYTPlayerStatePaused;
    } else if ([stateString isEqualToString:kYTPlayerStateBufferingCode]) {
        state = kYTPlayerStateBuffering;
    } else if ([stateString isEqualToString:kYTPlayerStateCuedCode]) {
        state = kYTPlayerStateQueued;
    }
    return state;
}
    
    /**
     * Convert a state value from the typed value to NSString.
     *
     * @param state A |YTPlayerState| parameter.
     * @return A string value to be used in the JavaScript bridge.
     */
+ (NSString *)stringForPlayerState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateUnstarted:
        return kYTPlayerStateUnstartedCode;
        case kYTPlayerStateEnded:
        return kYTPlayerStateEndedCode;
        case kYTPlayerStatePlaying:
        return kYTPlayerStatePlayingCode;
        case kYTPlayerStatePaused:
        return kYTPlayerStatePausedCode;
        case kYTPlayerStateBuffering:
        return kYTPlayerStateBufferingCode;
        case kYTPlayerStateQueued:
        return kYTPlayerStateCuedCode;
        default:
        return kYTPlayerStateUnknownCode;
    }
}
    
#pragma mark - Private methods
    
    /**
     * Private method to handle "navigation" to a callback URL of the format
     * ytplayer://action?data=someData
     * This is how the UIWebView communicates with the containing Objective-C code.
     * Side effects of this method are that it calls methods on this class's delegate.
     *
     * @param url A URL of the format ytplayer://action?data=value.
     */
- (void)notifyDelegateOfYouTubeCallbackUrl: (NSURL *) url {
    NSString *action = url.host;
    
    // We know the query can only be of the format ytplayer://action?data=SOMEVALUE,
    // so we parse out the value.
    //  NSString *query = url.query;
    NSString *data;
    
    NSDictionary *queryParams = [self paramsFromUrl:[url absoluteString]];
    data = [queryParams valueForKey:kYTPlayerCallbackDataKey];
    
    NSString *statusCallback = [queryParams valueForKey:kYTPlayerCallbackEventResponseCallbackKey];
    
    //  if (query) {
    //    data = [query componentsSeparatedByString:@"="][1];
    //  }
    
    if ([action isEqual:kYTPlayerCallbackOnReady]) {
        if (self.initialLoadingView) {
            [self.initialLoadingView removeFromSuperview];
        }
        self.isYTPlayerLoaded = YES;
        if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
            [self.delegate playerViewDidBecomeReady:self];
        }
    } else if ([action isEqual:kYTPlayerCallbackOnStateChange]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToState:)]) {
            YTPlayerState state = kYTPlayerStateUnknown;
            
            //        NSDictionary *queryParams = [self paramsFromUrl:[url absoluteString]];
            //
            //        data = [queryParams valueForKey:kYTPlayerCallbackDataKey];
            NSString *currTimeVal = [queryParams valueForKey:kYTPlayerCallbackOnPlayTime];
            if(currTimeVal){
                float time = [currTimeVal floatValue];
                [self.delegate playerView:self didPlayTime:time];
            }
            
            if ([data isEqual:kYTPlayerStateEndedCode]) {
                state = kYTPlayerStateEnded;
            } else if ([data isEqual:kYTPlayerStatePlayingCode]) {
                state = kYTPlayerStatePlaying;
            } else if ([data isEqual:kYTPlayerStatePausedCode]) {
                state = kYTPlayerStatePaused;
            } else if ([data isEqual:kYTPlayerStateBufferingCode]) {
                state = kYTPlayerStateBuffering;
            } else if ([data isEqual:kYTPlayerStateCuedCode]) {
                state = kYTPlayerStateQueued;
            } else if ([data isEqual:kYTPlayerStateUnstartedCode]) {
                state = kYTPlayerStateUnstarted;
            }
            
            
            
            [self.delegate playerView:self didChangeToState:state];
        }
    } else if ([action isEqual:kYTPlayerCallbackOnPlaybackQualityChange]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToQuality:)]) {
            YTPlaybackQuality quality = [InlineYoutubeView playbackQualityForString:data];
            [self.delegate playerView:self didChangeToQuality:quality];
        }
    } else if ([action isEqual:kYTPlayerCallbackOnError]) {
        if ([self.delegate respondsToSelector:@selector(playerView:receivedError:)]) {
            YTPlayerError error = kYTPlayerErrorUnknown;
            
            if ([data isEqual:kYTPlayerErrorInvalidParamErrorCode]) {
                error = kYTPlayerErrorInvalidParam;
            } else if ([data isEqual:kYTPlayerErrorHTML5ErrorCode]) {
                error = kYTPlayerErrorHTML5Error;
            } else if ([data isEqual:kYTPlayerErrorNotEmbeddableErrorCode] ||
                       [data isEqual:kYTPlayerErrorSameAsNotEmbeddableErrorCode]) {
                error = kYTPlayerErrorNotEmbeddable;
            } else if ([data isEqual:kYTPlayerErrorVideoNotFoundErrorCode] ||
                       [data isEqual:kYTPlayerErrorCannotFindVideoErrorCode]) {
                error = kYTPlayerErrorVideoNotFound;
            }
            
            [self.delegate playerView:self receivedError:error];
        }
    } else if ([action isEqualToString:kYTPlayerCallbackOnPlayTime]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didPlayTime:)]) {
            float time = [data floatValue];
            [self.delegate playerView:self didPlayTime:time];
        }
    } else if ([action isEqualToString:kYTPlayerCallbackOnDuration]) {
        if ([self.delegate respondsToSelector:@selector(playerView:duration:)]) {
            NSTimeInterval duration = [data doubleValue];
            [self.delegate playerView:self duration:duration];
        }
    }else if ([action isEqualToString:kYTPlayerCallbackOnYouTubeIframeAPIFailedToLoad]) {
        if (self.initialLoadingView) {
            [self.initialLoadingView removeFromSuperview];
        }
        [self.delegate playerView:self receivedError:kYTPlayerErrorIFrameAPIFailedToLoad];
        
    }
    
    if(statusCallback){
        [self getStringFromEvaluatingJavaScript:statusCallback completionHandler:nil];
    }
}
    
- (NSDictionary *) paramsFromUrl:(NSString *) strUrl {
    NSURL * url = [NSURL URLWithString:strUrl];
    
    NSURLComponents * components = [[NSURLComponents alloc]init];
    if (url) {
        components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    }
    NSString * query = [components query];
    if(!query) {
        return @{};
    }
    
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        NSArray <NSURLQueryItem *>  *queryItems = [components queryItems];
        for(NSURLQueryItem * item in queryItems) {
            [params setValue:item.value forKey:item.name];
        }
    } else {
        NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [params setObject:value forKey:key];
        }
    }
    return params;
}
    
- (BOOL)handleHttpNavigationToUrl:(NSURL *) url {
    // Usually this means the user has clicked on the YouTube logo or an error message in the
    // player. Most URLs should open in the browser. The only http(s) URL that should open in this
    // UIWebView is the URL for the embed, which is of the format:
    //     http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
    NSError *error = NULL;
    NSRegularExpression *ytRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerEmbedUrlRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *ytMatch =
    [ytRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *adRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerAdUrlRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *adMatch =
    [adRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *syndicationRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerSyndicationRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    
    NSTextCheckingResult *syndicationMatch =
    [syndicationRegex firstMatchInString:url.absoluteString
                                 options:0
                                   range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *oauthRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerOAuthRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *oauthMatch =
    [oauthRegex firstMatchInString:url.absoluteString
                           options:0
                             range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *staticProxyRegex =
    [NSRegularExpression regularExpressionWithPattern:kYTPlayerStaticProxyRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *staticProxyMatch =
    [staticProxyRegex firstMatchInString:url.absoluteString
                                 options:0
                                   range:NSMakeRange(0, [url.absoluteString length])];
    
    if (ytMatch || adMatch || oauthMatch || staticProxyMatch || syndicationMatch) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
}
    
    
    /**
     * Private helper method to load an iframe player with the given player parameters.
     *
     * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
     *                               to instantiate the HTML5 player with. This differs depending on
     *                               whether a single video or playlist is being loaded.
     * @return YES if successful, NO if not.
     */
- (BOOL)loadWithPlayerParams:(NSDictionary *)additionalPlayerParams {
    NSDictionary *playerCallbacks = @{
                                      @"onReady" : @"onReady",
                                      @"onStateChange" : @"onStateChange",
                                      @"onPlaybackQualityChange" : @"onPlaybackQualityChange",
                                      @"onError" : @"onPlayerError"
                                      };
    NSMutableDictionary *playerParams = [[NSMutableDictionary alloc] init];
    if (additionalPlayerParams) {
        [playerParams addEntriesFromDictionary:additionalPlayerParams];
    }
    if (![playerParams objectForKey:@"height"]) {
        [playerParams setValue:@"100%" forKey:@"height"];
    }
    if (![playerParams objectForKey:@"width"]) {
        [playerParams setValue:@"100%" forKey:@"width"];
    }
    
    [playerParams setValue:playerCallbacks forKey:@"events"];
    
    if ([playerParams objectForKey:@"playerVars"]) {
        NSMutableDictionary *playerVars = [[NSMutableDictionary alloc] init];
        [playerVars addEntriesFromDictionary:[playerParams objectForKey:@"playerVars"]];
        
        if (![playerVars objectForKey:@"origin"]) {
            self.originURL = [NSURL URLWithString:@"about:blank"];
        } else {
            self.originURL = [NSURL URLWithString: [playerVars objectForKey:@"origin"]];
        }
    } else {
        // This must not be empty so we can render a '{}' in the output JSON
        [playerParams setValue:[[NSDictionary alloc] init] forKey:@"playerVars"];
    }
    
    [self setupWebView];
    NSError *error = nil;
    NSString *path = [[NSBundle bundleForClass:[InlineYoutubeView class]] pathForResource:@"YTPlayerView-iframe-player"
                                                                              ofType:@"html"
                                                                         inDirectory:@"Assets"];
    
    // in case of using Swift and embedded frameworks, resources included not in main bundle,
    // but in framework bundle
    if (!path) {
        path = [[[self class] frameworkBundle] pathForResource:@"YTPlayerView-iframe-player"
                                                        ofType:@"html"
                                                   inDirectory:@"Assets"];
    }
    
    NSString *embedHTMLTemplate =
    [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Received error rendering template: %@", error);
        return NO;
    }
    
    // Render the playerVars as a JSON dictionary.
    NSError *jsonRenderingError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonRenderingError];
    if (jsonRenderingError) {
        NSLog(@"Attempted configuration of player with invalid playerVars: %@ \tError: %@",
              playerParams,
              jsonRenderingError);
        return NO;
    }
    
    NSString *playerVarsJsonString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *embedHTML = [NSString stringWithFormat:embedHTMLTemplate, playerVarsJsonString];
    [self.webView loadHTMLString:embedHTML baseURL: self.originURL];
    self.webView.navigationDelegate=self;
    self.webView.UIDelegate=self;
    
    [self setupInitialLoadingScreen];
    
    return YES;
}
    
- (BOOL)loadYTIframe{
    [self setupWebView];
    
    if(!self.isYTPlayerLoaded){
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.htmlUrl]];
    }
    
    self.webView.navigationDelegate=self;
    self.webView.UIDelegate=self;
    
    [self setupInitialLoadingScreen];
    
    return self.isYTPlayerLoaded;
    
}
    
-(void) setupWebView{
    
    if(self.webView){
        //webview already set
        [self.webView setFrame:self.bounds];
        return;
    }
    
    // Remove the existing webView to reset any state
    self.isYTPlayerLoaded = NO;
    [self.webView removeFromSuperview];
    _webView = [self createNewWebView];
    [self addSubview:self.webView];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    NSArray *constraints = @[topConstraint, leftConstraint, rightConstraint, bottomConstraint];
    [self addConstraints:constraints];
    
}
    
-(void) setupInitialLoadingScreen{
    if ([self.delegate respondsToSelector:@selector(playerViewPreferredInitialLoadingView:)]) {
        UIView *initialLoadingView = [self.delegate playerViewPreferredInitialLoadingView:self];
        if (initialLoadingView) {
            initialLoadingView.frame = self.bounds;
            initialLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:initialLoadingView];
            self.initialLoadingView = initialLoadingView;
        }
    }
}
    /**
     * Private method for cueing both cases of playlist ID and array of video IDs. Cueing
     * a playlist does not start playback.
     *
     * @param cueingString A JavaScript string representing an array, playlist ID or list of
     *                     video IDs to play with the playlist player.
     * @param index 0-index position of video to start playback on.
     * @param startSeconds Seconds after start of video to begin playback.
     * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
     */
- (void)cuePlaylist:(NSString *)cueingString
              index:(int)index
       startSeconds:(float)startSeconds
   suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *indexValue = [NSNumber numberWithInt:index];
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cuePlaylist(%@, %@, %@, '%@');",
                         cueingString, indexValue, startSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
    /**
     * Private method for loading both cases of playlist ID and array of video IDs. Loading
     * a playlist automatically starts playback.
     *
     * @param cueingString A JavaScript string representing an array, playlist ID or list of
     *                     video IDs to play with the playlist player.
     * @param index 0-index position of video to start playback on.
     * @param startSeconds Seconds after start of video to begin playback.
     * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
     */
- (void)loadPlaylist:(NSString *)cueingString
               index:(int)index
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *indexValue = [NSNumber numberWithInt:index];
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [InlineYoutubeView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadPlaylist(%@, %@, %@, '%@');",
                         cueingString, indexValue, startSecondsValue, qualityValue];
    [self getStringFromEvaluatingJavaScript:command completionHandler:nil];
}
    
    /**
     * Private helper method for converting an NSArray of video IDs into its JavaScript equivalent.
     *
     * @param videoIds An array of video ID strings to convert into JavaScript format.
     * @return A JavaScript array in String format containing video IDs.
     */
- (NSString *)stringFromVideoIdArray:(NSArray *)videoIds {
    NSMutableArray *formattedVideoIds = [[NSMutableArray alloc] init];
    
    for (id unformattedId in videoIds) {
        [formattedVideoIds addObject:[NSString stringWithFormat:@"'%@'", unformattedId]];
    }
    
    return [NSString stringWithFormat:@"[%@]", [formattedVideoIds componentsJoinedByString:@", "]];
}
    
    /**
     * Private method for evaluating JavaScript in the WebView.
     *
     * @param jsToExecute The JavaScript code in string format that we want to execute.
     */
- (void)getStringFromEvaluatingJavaScript:(NSString *)jsToExecute completionHandler:(void (^ __nullable)(NSString * __nullable response, NSError * __nullable error))completionHandler{
    [self.webView evaluateJavaScript:jsToExecute completionHandler:^(id response, NSError *error) {
        
        // in 8.x os, there is a crash in wkwebview when webview is destroyed while a js string is being evaluated. Hence holding a string reference to wkwebview till js execution finishes for this command.
        //        https://bugs.webkit.org/show_bug.cgi?id=140203
        //        http://stackoverflow.com/questions/27021201/possible-crash-with-wkwebview
        InlineYoutubeView * dummy = nil;
        if(SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            dummy = self;
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
        dummy = nil;
    }];
}
    
- (WKWebView *)createNewWebView {
    // WKWebView equivalent for UIWebView's scalesPageToFit
    // http://stackoverflow.com/questions/26295277/wkwebview-equivalent-for-uiwebviews-scalespagetofit
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *webViewConfiguration=[[WKWebViewConfiguration alloc]init];
    
    [webViewConfiguration setUserContentController:wkUController];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")&&SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [webViewConfiguration setMediaPlaybackRequiresUserAction:NO];
    }
    else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")&&SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [webViewConfiguration setRequiresUserActionForMediaPlayback:NO];
    }
    else  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        [webViewConfiguration setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];
    }
    
    
    BOOL shouldPlayInline;
    if (self.videoPlayerMode == kYTPlayerModeFullScreen) {
        shouldPlayInline = NO;
    } else {
        shouldPlayInline = YES;
    }
    
    [webViewConfiguration setAllowsInlineMediaPlayback: shouldPlayInline];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")&&SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [webViewConfiguration setMediaPlaybackAllowsAirPlay:NO];
    }
    else{
        [webViewConfiguration setAllowsAirPlayForMediaPlayback:NO];
    }
    
    
    WKWebView *webView=[[WKWebView alloc]initWithFrame:self.bounds configuration:webViewConfiguration];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    
    if ([self.delegate respondsToSelector:@selector(playerViewPreferredWebViewBackgroundColor:)]) {
        webView.backgroundColor = [self.delegate playerViewPreferredWebViewBackgroundColor:self];
        if (webView.backgroundColor == [UIColor clearColor]) {
            webView.opaque = NO;
        }
    }
    
    return webView;
}
    
    /**
     * Private method to convert a Objective-C BOOL value to JS boolean value.
     *
     * @param boolValue Objective-C BOOL value.
     * @return JavaScript Boolean value, i.e. "true" or "false".
     */
- (NSString *)stringForJSBoolean:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}
    
#pragma mark - Exposed for Testing
    
- (void)setWebView:(WKWebView *)webView {
    _webView = webView;
}
    
- (void)removeWebView {
    [self.webView removeFromSuperview];
    self.webView = nil;
}
    
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Assets.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}
    
    @end

