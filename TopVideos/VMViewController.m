//
//  VMViewController.m
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "VMViewController.h"
#import <VevoSDK/VMApiFacade.h>
#import "VMConstants.h"
#import "VMTopVideosTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VMViewController ()

@end

@implementation VMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    topVideos = [[NSMutableDictionary alloc] init];
    
   // [VMApiFacade getTopVideosForOrder:(NSString *)orderString genre:(NSString *)genre offset:(int)offset limit:(int)limit successBlock:(Void_Id)successBlock errorBlock:(Void_Id)errorBlock];
    
    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:@"" offset:0 limit:TOP_VIDEOS_LOAD_COUNT
                         successBlock:^(id results){
                             
                             NSLog(@"%@",results);
                             
                             //set top videos dictionary and reload data
                             [topVideos setValue:results forKey:@"default"];
                             [self.tableView reloadData];
                             
                         }
                         errorBlock:^(NSError *error){
                           NSLog(@"%@",error);
                         }];
    
    //hide status bar
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //setup tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TOP_VIDEOS_LOAD_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"top_videos_cell";
    VMTopVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[VMTopVideosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *topVideo = [[topVideos objectForKey:@"default"] objectAtIndex:indexPath.row];
    
    cell.songTitleLabel.text = [topVideo objectForKey:@"title"];
    [cell.artistImageView setImageWithURL:[NSURL URLWithString:[topVideo objectForKey:@"image_url"]]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

@end
