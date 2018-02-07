//
//  YTViewController.m
//  InlineYoutubeView
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

#import "YTViewController.h"
#import "YTVideoCell.h"

NSString * const videoIds[] = {
    @"2Vv-BfVoq4g", @"D5drYkLiLI8", @"K0ibBPhiaG0", @"ebXbLfLACGM", @"mWRsgZuwf_8"
};

CGFloat const VIDEO_INSET = 5;

@interface YTViewController ()
    @property (nonatomic, strong) UITableView *tableView;
    @property (nonatomic, assign) CGFloat videoWidth;
    @property (nonatomic, assign) CGFloat videoHeight;
    @end

@implementation YTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.bounces = NO;
    [self.view addSubview:self.tableView];
    
    _videoWidth = UIScreen.mainScreen.bounds.size.width - 2 * VIDEO_INSET;
    _videoHeight = (_videoWidth * 9) / 16 ; //Maintain the 16:9 aspect ratio according to youtube standards
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGRect videoRect = CGRectMake(VIDEO_INSET, VIDEO_INSET, _videoWidth, _videoHeight);
    if(indexPath.section == 0) {
        YTVideoCell *videoCell = [[YTVideoCell alloc] initWithFrame:videoRect andVideoId:videoIds[indexPath.row] andShouldPlayInline:YES];
        return videoCell;
    } else {
        YTVideoCell *videoCell = [[YTVideoCell alloc] initWithFrame:videoRect andVideoId:videoIds[indexPath.row] andShouldPlayInline:NO];
        return videoCell;
    }
}
    
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _videoHeight + 2 * VIDEO_INSET;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 50)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    if(section == 0) {
        [label setText:@"InlineVideos"];
    } else {
        [label setText:@"FullScreenVideos"];
    }
    [view addSubview:label];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YTVideoCell *videoCell = [tableView cellForRowAtIndexPath:indexPath];
    [videoCell playButtonClicked];
}

    


    @end
