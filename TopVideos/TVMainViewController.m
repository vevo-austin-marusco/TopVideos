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

//view constants
float const kTableViewCellHeightRatio       = 0.5;
float const kTableViewSectionHeightRatio    = 0.04;
float const kVideoViewHeightRatio           = 0.38;

//color constants
float const kSelectedGenreColorR = 3/255.0f;
float const kSelectedGenreColorG = 207/255.0f;
float const kSelectedGenreColorB = 235/255.0f;

@interface TVMainViewController ()

@property (nonatomic) bool playingAds;
@property (nonatomic, retain) TVMovieContainerView *movieContainerView;
@property (nonatomic, retain) NSString *selectedGenre;


@end

@implementation TVMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpened) name:@"APP_OPENED" object:nil];
    
    self.playingAds = NO;
    
    //default genre selection
    self.selectedGenre = @"top_40_all";
    
    //gestures
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGestureForSwipeRecognizer:)];
    [leftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    leftGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightGestureForSwipeRecognizer:)];
    [rightGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    rightGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:rightGestureRecognizer];
    
    //setup tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //hide status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
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
    return kTopVideosLoadCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIApplication sharedApplication].keyWindow.rootViewController.view.frame.size.height * kTableViewCellHeightRatio;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIApplication sharedApplication].keyWindow.rootViewController.view.frame.size.height * kTableViewSectionHeightRatio;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              self.view.frame.size.width,
                                                                              [UIApplication sharedApplication].keyWindow.rootViewController.view.frame.size.height * kTableViewSectionHeightRatio)];
    
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.clipsToBounds = YES;
    scrollView.userInteractionEnabled = NO;
    
    //setup all the scroll view pages
    for(int i = 0; i < [APP_DELEGATE.genres count]; i++){
        //setup selected genre label
        CGFloat xOrigin = (i  * self.view.frame.size.width/4);
        UILabel *genreLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin,
                                                                        0,
                                                                        self.view.frame.size.width/4,
                                                                        [UIApplication sharedApplication].keyWindow.rootViewController.view.frame.size.height * kTableViewSectionHeightRatio)];
        genreLabel.font = [UIFont fontWithName:@"ProximaNovaA-Bold" size:10];
        genreLabel.textAlignment = NSTextAlignmentCenter;
        
        //set the middle label to a difference color
        if(i == 0){
          genreLabel.textColor = [UIColor colorWithRed:kSelectedGenreColorR green:kSelectedGenreColorG blue:kSelectedGenreColorB alpha:1.0];
        }
        else{
          genreLabel.textColor = [UIColor whiteColor];
        }
        
        //set the text to the appropriate value w/ offset
        genreLabel.text = [APP_DELEGATE.genres objectAtIndex:i];
        
        [scrollView addSubview:genreLabel];
    }
    
    //set current page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width/4 * [self getCurrentGenreIndex];
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:NO];
    
    self.genresView = scrollView;
    
    return scrollView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"top_videos_cell";
    TVTopVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[TVTopVideosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //if there are values in the array, load into tableview
    if([[APP_DELEGATE.genreData objectAtIndex:[self getCurrentGenreIndex]] count] > 0){
            //load song dictionary
            NSDictionary *topVideo = [[APP_DELEGATE.genreData  objectAtIndex:[self getCurrentGenreIndex]] objectAtIndex:indexPath.row];
            
            //set cell properties
            cell.songTitleLabel.text = [[topVideo objectForKey:@"title"] uppercaseString];
            cell.artistNameLabel.text = [[[[topVideo objectForKey:@"artists_main"] objectAtIndex:0] objectForKey:@"name"] uppercaseString];
            [cell.artistImageView setImageWithURL:[NSURL URLWithString:[topVideo objectForKey:@"image_url"]]
                                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            NSNumber *tempTopVideoCount = [NSNumber numberWithInt:indexPath.row + 1];
            cell.topVideoCountLabel.text = [tempTopVideoCount stringValue];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //if the app is not playing adds, allow user to select
    if(!self.playingAds){
    
        NSString *isrcTempString = [[[APP_DELEGATE.genreData  objectAtIndex:[self getCurrentGenreIndex]] objectAtIndex:indexPath.row] valueForKey:@"isrc"];
        
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
                                                                                                      -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                                                      self.view.frame.size.width,
                                                                                                      self.view.frame.size.height * kVideoViewHeightRatio) DelegateObject:self];
    [self.view addSubview:self.movieContainerView];
    
    //add the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.movieContainerView.frame = CGRectMake(0,
                                                                      0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height * kVideoViewHeightRatio);
                         NSLog(@"frame=%@", NSStringFromCGRect(self.movieContainerView.frame));
                         self.tableView.frame = CGRectMake(0, self.view.frame.size.height * kVideoViewHeightRatio, self.view.frame.size.width, self.view.frame.size.height * (1 - kVideoViewHeightRatio));
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
                                                                    -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height * kVideoViewHeightRatio);
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
    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:@"" offset:0 limit:kTopVideosLoadCount
                                          successBlock:^(id results){
                                              
                                              NSLog(@"%@",results);
                                              
                                              //set top videos dictionary and reload data
                                              [APP_DELEGATE.genreData replaceObjectAtIndex:[self getCurrentGenreIndex] withObject:results];
                                              [self.tableView reloadData];
                                              
                                          }
                                            errorBlock:^(NSError *error){
                                                NSLog(@"%@",error);
                                            }];
}

// used for status bar preferrences
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//return the index of the selected genre
- (int)getCurrentGenreIndex
{
    int index = 0;
    
    for(NSString *object in APP_DELEGATE.genres){
        if([object isEqualToString:self.selectedGenre]){
            return index;
        }
        index += 1;
    }
    
    return 0;
}

//return the correct offset index for an array
- (int)getOffsetValueWithArray:(NSMutableArray *)inputArray Offset:(int)offset Index:(int)index
{
    int tempIndex = index;
    
    if(offset > 0){
        for(int i = 0; i < offset; i++){
            if(tempIndex == [inputArray count] - 1){
                tempIndex = 0;
            }
            else{
                tempIndex += 1;
            }
        }
    }
    else{
        for(int i = 0; i < (0 - offset); i++){
            if(tempIndex == 0){
                tempIndex = [inputArray count] - 1;
            }
            else{
                tempIndex -= 1;
            }
        }
    }
    
    return tempIndex;
}

//returns a genre that corresponds with a given index
- (NSString *)getGenreForIndex:(int)index
{
    return [APP_DELEGATE.genres objectAtIndex:index];
}

#pragma mark - ads
- (void)startedPlayingAds
{
    self.playingAds = YES;
    NSLog(@"ads");
}

- (void)stoppedPlayingAds
{
    self.playingAds = NO;
    NSLog(@" no ads");
}

#pragma mark - gestures
//user swipes to the left on tableview
- (void)leftGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    //remove the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                        int newIndexAfterSwipe = -1;
                         
                        if([self getCurrentGenreIndex] == [APP_DELEGATE.genres count] - 1){
                          newIndexAfterSwipe = 0;
                        }
                        else{
                          newIndexAfterSwipe = [self getCurrentGenreIndex] + 1;
                        }
                         
                         self.selectedGenre = [APP_DELEGATE.genres objectAtIndex:newIndexAfterSwipe];
                         
                         CGRect frame = self.genresView.frame;
                         frame.origin.x = frame.size.width/4 * [self getCurrentGenreIndex];
                         frame.origin.y = 0;
                         [self.genresView scrollRectToVisible:frame animated:YES];
                         
                         //get list of videos from server and reload tableview when finished
                     /*    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:@"" offset:0 limit:kTopVideosLoadCount
                                                       successBlock:^(id results){
                                                           
                                                           NSLog(@"%@",results);
                                                           
                                                           //set top videos dictionary and reload data
                                                           [APP_DELEGATE.genreData replaceObjectAtIndex:[self getCurrentGenreIndex] withObject:results];
                                                           [self.tableView reloadData];
                                                           
                                                       }
                                                         errorBlock:^(NSError *error){
                                                             NSLog(@"%@",error);
                                                         }];
                      */
                     }
                     completion:^(BOOL finished){

                     }];
}
//user swipes to the right on tableview
- (void)rightGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    
}

@end
