//
//  YTViewController.m
//  InlineYoutubeView
//
//  Created by shubhankaryash on 01/31/2018.
//  Copyright © 2018 flipkart.com. All rights reserved.
//

#import "YTViewController.h"
#import "YTVideoCell.h"

NSString * const videoIds[] = {
    @"2Vv-BfVoq4g", @"D5drYkLiLI8", @"K0ibBPhiaG0", @"ebXbLfLACGM", @"mWRsgZuwf_8"
};

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
    [self.view addSubview:self.tableView];
    
    _videoWidth = UIScreen.mainScreen.bounds.size.width;
    _videoHeight = (_videoWidth * 9) / 16 ; //Maintain the 16:9 aspect ratio according to youtube standards
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGRect videoRect = CGRectMake(0, 0, _videoWidth, _videoHeight);
    if(indexPath.row == 4) {
        YTVideoCell *videoCell = [[YTVideoCell alloc] initWithFrame:videoRect andVideoId:videoIds[indexPath.row] andShouldPlayInline:NO];
        return videoCell;
    } else {
        YTVideoCell *videoCell = [[YTVideoCell alloc] initWithFrame:videoRect andVideoId:videoIds[indexPath.row] andShouldPlayInline:YES];
        return videoCell;
    }
}
    
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _videoHeight;
}
    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YTVideoCell *videoCell = [tableView cellForRowAtIndexPath:indexPath];
    [videoCell playButtonClicked];
}

    


    @end
