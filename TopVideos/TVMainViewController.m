//
//  VMViewController.m
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import "TVMainViewController.h"
#import <VevoSDK/VMApiFacade.h>
#import <VevoSDK/VMMoviePlayerController.h>
#import <VevoSDK/VMConstants.h>
#import <VevoSDK/VMVideo.h>
#import "TVConstants.h"
#import "TVTopVideosTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TVMovieContainerView.h"

#define TABLEVIEW_CELL_HEIGHT 240
#define VIDEO_VIEW_HEIGHT_RATIO 0.38

@interface TVMainViewController ()

@property (nonatomic, retain) TVMovieContainerView *movieContainerView;

@end

@implementation TVMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    topVideos = [[NSMutableDictionary alloc] init];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpened) name:@"APP_OPENED" object:nil];
    
    playingAds = NO;
    
    //setup tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   //TO-DO Add code to shift orientation
    [self.view layoutSubviews];
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TOP_VIDEOS_LOAD_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"top_videos_cell";
    TVTopVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[TVTopVideosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //load song dictionary
    NSDictionary *topVideo = [[topVideos objectForKey:@"default"] objectAtIndex:indexPath.row];
    
    //set cell properties
    cell.songTitleLabel.text = [[topVideo objectForKey:@"title"] uppercaseString];
    cell.artistNameLabel.text = [[[[topVideo objectForKey:@"artists_main"] objectAtIndex:0] objectForKey:@"name"] uppercaseString];
    [cell.artistImageView setImageWithURL:[NSURL URLWithString:[topVideo objectForKey:@"image_url"]]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    NSNumber *tempTopVideoCount = [NSNumber numberWithInt:indexPath.row + 1];
    cell.topVideoCountLabel.text = [tempTopVideoCount stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //if the app is not playing adds, allow user to select
    if(!playingAds){
    
        NSString *isrcTempString = [[[topVideos objectForKey:@"default"] objectAtIndex:indexPath.row] valueForKey:@"isrc"];
        
        //retrieve video information from server
        [[VMApiFacade sharedInstance] searchWithIsrc:isrcTempString successBlock:^(id results){
            
                    NSLog(@"success %@",results);
                    VMVideo *video = [[VMVideo alloc] initFromDictionary:results];
            
            //nil case
            if (video != nil) {
                //valid video case
                if (video) {
                    
                    bool movieViewInController = NO;
                    
                    //check to see if the movieView is on the screen
                    for(UIView *object in self.view.subviews){
                        if([object class] == [TVMovieContainerView class]){
                            movieViewInController = YES;
                        }
                    }
                    
                    //if the view is on screen, play video
                    if(movieViewInController){
                        [self.movieContainerView stopVideo];
                        [self.movieContainerView playVideo:video];
                    }
                    //if the view is not on screen, insert the view
                    else{
                      [self insertVideoPlayerWithVideo:video];
                    }
                }
            }
            }
              errorBlock:^(NSError *error){
                  NSLog(@"failure %@",error);
              }];
        
    }
}

#pragma mark - play video
- (void)insertVideoPlayerWithVideo:(VMVideo *)video
{
    self.movieContainerView = [[TVMovieContainerView alloc] initWithFrame:CGRectMake(0,
                                                                                                      -(self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO),
                                                                                                      self.view.frame.size.width,
                                                                                                      self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO) DelegateObject:self];
    [self.view addSubview:self.movieContainerView];
    
    //add the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.movieContainerView.frame = CGRectMake(0,
                                                                      0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO);
                         NSLog(@"frame=%@", NSStringFromCGRect(self.movieContainerView.frame));
                         self.tableView.frame = CGRectMake(0, self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO, self.view.frame.size.width, self.view.frame.size.height * (1 - VIDEO_VIEW_HEIGHT_RATIO));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
    [self.movieContainerView playVideo:video];
}
- (void)removeVideoPlayer
{
    //remove the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         self.movieContainerView.frame = CGRectMake(0,
                                                                    -(self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO),
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height * VIDEO_VIEW_HEIGHT_RATIO);
                     }
                     completion:^(BOOL finished){
                         //find the TVMovieContainerView and remove it
                         for(UIView *object in self.view.subviews){
                             if([object class] == [TVMovieContainerView class]){
                                 [object removeFromSuperview];
                             }
                         }
                     }];
}

#pragma mark - other
- (void)appOpened{
    //get list of videos from server and reload tableview when finished
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
}

#pragma mark - ads
- (void)startedPlayingAds
{
    playingAds = YES;
    NSLog(@"ads");
}

- (void)stoppedPlayingAds
{
    playingAds = NO;
    NSLog(@" no ads");
}

@end
