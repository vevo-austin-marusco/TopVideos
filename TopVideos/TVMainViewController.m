//
//  TVViewController.m
//  TopVideos
//
//  Created by Austin Marusco on 9/3/13.
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
#import <VevoSDK/VMConstants.h>
#import <VevoSDK/VMPlayerOverlayObject.h>
#import "TVPlayerTopBarView.h"

//view constants
float const kTableViewCellHeightRatio       = 0.5;
float const kTableViewSectionHeightRatio    = 0.04;
float const kVideoViewHeightRatio           = 0.38;

//color constants
float const kSelectedGenreColorR = 3/255.0f;
float const kSelectedGenreColorG = 207/255.0f;
float const kSelectedGenreColorB = 235/255.0f;

//refresh constants
//refresh after n days
int const kRefreshAllDataAfter = 7;

@interface TVMainViewController (){}

@property (nonatomic) int page;
@property (nonatomic) bool playingAds;
@property (nonatomic, strong) VMVideo *video;
@property (nonatomic, strong) NSMutableDictionary *recentlyReloadedGenres;

//scroll views
@property (nonatomic,retain) UIScrollView *genresView;
@property (nonatomic,retain) UIScrollView *topVideosScrollView;

//movie player
@property (nonatomic, strong) VMMoviePlayerController *vodPlayer;
@property (nonatomic, strong) UIView *playerContainerViewBackground;
@property (nonatomic, strong) UIView *playerContainerView;

@end

@implementation TVMainViewController

@synthesize playerContainerView = _playerContainerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpened) name:@"APP_OPENED" object:nil];
    
    //set controller's initial variables
    self.playingAds = NO;
    self.page = 0;
    
    //hide status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    /*
     setup scrollview
    */
    self.topVideosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                             [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio,
                                                                              self.view.frame.size.width,
                                                                              self.view.frame.size.height - ([[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio))];
    self.topVideosScrollView.pagingEnabled = YES;
    self.topVideosScrollView.backgroundColor = [UIColor whiteColor];
    self.topVideosScrollView.userInteractionEnabled = YES;
    self.topVideosScrollView.delegate = self;
    self.topVideosScrollView.contentSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width * [APP_DELEGATE.genres count],
                                                      [[UIScreen mainScreen]bounds].size.height - ([[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio));
    self.topVideosScrollView.showsHorizontalScrollIndicator = NO;
    self.topVideosScrollView.showsVerticalScrollIndicator = NO;
    self.topVideosScrollView.bounces = NO;
    self.topVideosScrollView.directionalLockEnabled = NO;
    
    //setup all the scroll view pages
    for(int i = 0; i < [APP_DELEGATE.genres count]; i++){
        //setup selected genre label
        CGFloat xOrigin = (i  * self.view.frame.size.width);
        UITableView *genreTableView = [[UITableView alloc] initWithFrame:CGRectMake(xOrigin,
                                                                        0,
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height - [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio)];
        genreTableView.delegate = self;
        genreTableView.dataSource = self;
        genreTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        genreTableView.bounces = YES;
        genreTableView.clipsToBounds = YES;
        genreTableView.directionalLockEnabled = NO;
        //add 1 to tag becuase '0' is always the superview
        genreTableView.tag = i + 1;
        
        [self.topVideosScrollView addSubview:genreTableView];
    }
    
    //set current page
    CGRect frame = self.topVideosScrollView.frame;
    frame.origin.x = frame.size.width * self.page;
    [self.topVideosScrollView scrollRectToVisible:frame animated:NO];
    
    /*
     setup genre scroll view
    */
    self.genresView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.view.frame.size.width,
                                                                      [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio)];
    self.genresView.contentSize = CGSizeMake(([[UIScreen mainScreen]bounds].size.width/4 * [APP_DELEGATE.genres count]) + (2 * [[UIScreen mainScreen]bounds].size.width/4),
                                                      [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio);
    
    self.genresView.pagingEnabled = YES;
    self.genresView.backgroundColor = [UIColor blackColor];
    self.genresView.clipsToBounds = YES;
    self.genresView.userInteractionEnabled = NO;
    
    //setup the initial two blank scroll view pages
    //setup all the scroll view pages
    int blankLabels = 2;
    for(int i = 0; i < blankLabels; i++){
        //setup selected genre label
        CGFloat xOrigin = (i  * self.view.frame.size.width/4 - self.view.frame.size.width/8);
        UILabel *genreLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin,
                                                                        0,
                                                                        self.view.frame.size.width/4,
                                                                        [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio)];
        [self.genresView addSubview:genreLabel];
    }
    
    //setup all the scroll view pages
    for(int i = 0; i < [APP_DELEGATE.genres count]; i++){
        //setup selected genre label
        CGFloat xOrigin = ((i + blankLabels)  * self.view.frame.size.width/4) - self.view.frame.size.width/8;
        UILabel *genreLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin,
                                                                        0,
                                                                        self.view.frame.size.width/4,
                                                                        [[UIScreen mainScreen]bounds].size.height * kTableViewSectionHeightRatio)];
        genreLabel.font = [UIFont fontWithName:@"ProximaNovaA-Bold" size:13];
        genreLabel.textAlignment = NSTextAlignmentCenter;
        
        //set the middle label to a difference color
        if(i == 0){
            genreLabel.textColor = [UIColor colorWithRed:kSelectedGenreColorR green:kSelectedGenreColorG blue:kSelectedGenreColorB alpha:1.0];
        }
        else{
            genreLabel.textColor = [UIColor whiteColor];
        }
        
        //set the text to the appropriate value w/ offset
        genreLabel.text = [[APP_DELEGATE.genreDetails objectForKey:[APP_DELEGATE.genres objectAtIndex:i]] uppercaseString];
        genreLabel.tag = i + 1;
        
        [self.genresView addSubview:genreLabel];
    }
    
    //add subviews to main view
    [self.view addSubview:self.genresView];
    [self.view addSubview:self.topVideosScrollView];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UIScreen mainScreen]bounds].size.height * kTableViewCellHeightRatio;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"top_videos_cell";
    TVTopVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[TVTopVideosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    //if there are values in the array, load into tableview
    int currentTableIndex = tableView.tag - 1;
    ;
    
    if([[self getDataForGenre:[self getGenreForIndex:currentTableIndex]] count] > 0){
            //load song dictionary
            NSDictionary *topVideo = [[self getDataForGenre:[self getGenreForIndex:currentTableIndex]] objectAtIndex:indexPath.row];
        
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
    [self moviePlayerStartPlayRecommendationAt:indexPath.row];
}

#pragma mark - play video
- (void)insertVideoPlayerWithVideo:(VMVideo *)video
{
    [self setupPlayerContainer];
    
    //add the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //shift the view frames
                         self.playerContainerView.frame = CGRectMake(0,
                                                                    0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height * kVideoViewHeightRatio);
                         self.playerContainerViewBackground.frame = CGRectMake(0,
                                                                     0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height * kVideoViewHeightRatio);
                         
                         self.genresView.frame = CGRectMake(0,
                                                            (self.view.frame.size.height * kVideoViewHeightRatio),
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height * kTableViewSectionHeightRatio);
                         
                         self.topVideosScrollView.frame =CGRectMake(0,
                                                                    self.view.frame.size.height * kVideoViewHeightRatio + self.view.frame.size.height * kTableViewSectionHeightRatio,
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height - (self.view.frame.size.height * kVideoViewHeightRatio) + (self.view.frame.size.height * kTableViewSectionHeightRatio));
                     }
                     completion:^(BOOL finished){
                         //set the content size
                         self.topVideosScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [APP_DELEGATE.genres count],
                                                                           self.view.frame.size.height - (self.view.frame.size.height * kTableViewSectionHeightRatio) - (self.view.frame.size.height * kVideoViewHeightRatio));
                     }];
    
    
    [self playVideo:video];
}
- (void)removeVideoPlayer
{
    //remove the video player view w/ animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //shift the view frames
                         self.topVideosScrollView.frame =CGRectMake(0,
                                                                    self.view.frame.size.height * kTableViewSectionHeightRatio,
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height - (self.view.frame.size.height * kTableViewSectionHeightRatio));

                         self.genresView.frame = CGRectMake(0,
                                                           0,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height * kTableViewSectionHeightRatio);
                         self.playerContainerView.frame = CGRectMake(0,
                                                                    -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height * kVideoViewHeightRatio);
                         self.playerContainerViewBackground.frame = CGRectMake(0,
                                                                     -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height * kVideoViewHeightRatio);
                     }
                     completion:^(BOOL finished){
                         //find the TVMovieContainerView and remove it
                         for(UIView *object in self.view.subviews){
                             if(object.tag == 1){
                                 [object removeFromSuperview];
                             }
                         }
                         
                         //shift the view frames
                         self.topVideosScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [APP_DELEGATE.genres count],
                                                                           self.view.frame.size.height - (self.view.frame.size.height * kTableViewSectionHeightRatio));
                     }];
}

-(void)moviePlayerEnterFullScreen
{
    // When the cell is touched, it should faint.
    [UIView animateWithDuration:.4 animations:^{
        
        //if the player is in the center of the screen, take the view out of full screen mode
        if(self.playerContainerViewBackground.frame.size.width == [[UIScreen mainScreen]bounds].size.width && self.playerContainerViewBackground.frame.size.height == [[UIScreen mainScreen]bounds].size.height){
            self.playerContainerView.frame = CGRectMake(0,
                                                        0,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height * kVideoViewHeightRatio);
            self.playerContainerViewBackground.frame = CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width,
                                                                  self.view.frame.size.height * kVideoViewHeightRatio);
        }
        //if the player is not in full screen mode, make full screen
        else{
            self.playerContainerView.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
            self.playerContainerViewBackground.frame = CGRectMake(0,
                                                        0,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height);
            
        }
        
        
    }completion:^(BOOL finished){}];
}

#pragma mark - genre views
- (void)reloadSelectedTableViewWithCurrentGenreIndex:(int)genreIndex
{
    NSLog(@"loading 0 %f",CACurrentMediaTime());
    //get list of videos from server and reload tableview when finished
    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:[APP_DELEGATE.genres objectAtIndex:genreIndex] offset:0 limit:kTopVideosLoadCount
                                          successBlock:^(id results){

                                              [self.recentlyReloadedGenres setValue:[NSNumber numberWithBool:YES] forKey:[self getGenreForIndex:genreIndex]];
                                              
                                              UITableView *currentTableView = (UITableView *)[self.topVideosScrollView viewWithTag:genreIndex + 1];
                                              
                                              //add 1 to tag becuase '0' is always the superview
                                              [currentTableView reloadData];
                                              
                                              //remove the activity indicator from the view
                                              [self removeActivityIndicatorFomView:currentTableView];
                                              
                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                  //set top videos dictionary and reload data
                                                  [self setDataForGenre:[self getGenreForIndex:genreIndex] Results:results];
                                              });
                                              
                                          }
                                            errorBlock:^(NSError *error){
                                                NSLog(@"%@",error);
                                            }];
}

//reload the genre at the index and the surrounding indexes
- (void)reloadSelectedTableViewsWithCurrentGenreIndex:(int)genreIndex
{
    //load current index
    //if the genre hasn't been recently refreshed
    if(![self.recentlyReloadedGenres objectForKey:[self getGenreForIndex:genreIndex]]){
        [self reloadSelectedTableViewWithCurrentGenreIndex:genreIndex];
    }
    
    //load previous index
    if(genreIndex != 0){
        //if the genre hasn't been recently refreshed
        if(![self.recentlyReloadedGenres objectForKey:[self getGenreForIndex:genreIndex-1]]){
            [self reloadSelectedTableViewWithCurrentGenreIndex:genreIndex-1];
        }
    }
    
    //load next index
    if(genreIndex != ([APP_DELEGATE.genres count] - 1)){
        //if the genre hasn't been recently refreshed
        if(![self.recentlyReloadedGenres objectForKey:[self getGenreForIndex:genreIndex+1]]){
            [self reloadSelectedTableViewWithCurrentGenreIndex:genreIndex+1];
        }
    }
}

//returns a genre that corresponds with a given index
- (NSString *)getGenreForIndex:(int)index
{
    return [APP_DELEGATE.genres objectAtIndex:index];
}

//return the array of data for a given genre
- (NSMutableArray *) getDataForGenre:(NSString *)genre
{
    
    if([APP_DELEGATE.genreData objectForKey:genre]){
        return [APP_DELEGATE.genreData objectForKey:genre];
    }
    
    return [NSMutableArray array];
}

//set the cached data for the genre
- (void)setDataForGenre:(NSString *)genre Results:(NSDictionary *)results
{
    [APP_DELEGATE.genreData setObject:results forKey:genre];
    
    //store values
    NSMutableDictionary *genreCache = [[NSMutableDictionary alloc] initWithObjectsAndKeys:APP_DELEGATE.genres,@"genrePossibleSelections",APP_DELEGATE.genreData,@"genreCache", nil];
    [[NSUserDefaults standardUserDefaults] setObject:genreCache forKey:@"genreInformation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - other
- (void)appOpened{
    //reload current page data
    [self reloadSelectedTableViewsWithCurrentGenreIndex:self.page];
    
    //reset recently reloaded genres
    self.recentlyReloadedGenres = [[NSMutableDictionary alloc] init];
}

// used for status bar preferrences
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) moviePlayerStartPlayRecommendationAt:(int)index
{
    //if the app is not playing adds, allow user to select
    if(!self.playingAds){
        
        if(index <= kTopVideosLoadCount){
        
           
            NSDictionary *genreData = [[self getDataForGenre:[self getGenreForIndex:index]] objectAtIndex:index];
            NSString *isrcTempString = [genreData valueForKey:@"isrc"];
            
            //retrieve video information from server
            [[VMApiFacade sharedInstance] searchWithIsrc:isrcTempString successBlock:^(id results){
                
                NSLog(@"success %@",results);
                VMVideo *video = [[VMVideo alloc] initFromDictionary:results];
                
                //nil case
                if (video != nil) {
                    //valid video case
                    if (video) {
                        
                        //if the view is on screen, play video
                        if([self moviePLayerOnScreen]){
                            [self stopVideo];
                            [self playVideo:video];
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
}

//returns true if the movie player is on screen
- (bool)moviePLayerOnScreen
{
    //check to see if the movieView is on the screen
    for(UIView *object in self.view.subviews){
        if(object.tag == 1){
            return YES;
        }
    }
    
    return NO;
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

#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Update the page when more than 50% of the previous/next page is visible
    if([scrollView class] != [UITableView class]){
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
            //if the page has changed, move the scroll view and set page variable
            if(page != self.page){
                self.page = page;
                
                  //scroll the view
                 [scrollView scrollRectToVisible:CGRectMake((scrollView.frame.size.width * self.page),
                                                                          0,
                                                                          scrollView.frame.size.width,
                                                                          scrollView.frame.size.height) animated:YES];
                
                //reload selected table view
                [self reloadSelectedTableViewsWithCurrentGenreIndex:self.page];
                
                //shift the genre scroll view
                [self.genresView scrollRectToVisible:CGRectMake((self.genresView.frame.size.width/4 * self.page),
                                                                         0,
                                                                         self.genresView.frame.size.width,
                                                                         self.genresView.frame.size.height) animated:YES];
                
                //set appropriate color for labels
                //set all the text colors to white
                for (UILabel *object in self.genresView.subviews){
                    if([object respondsToSelector:@selector(setTextColor:)]){
                        [object setTextColor:[UIColor whiteColor]];
                    }
                    
                }
                //find the current genre label and set text color
                UILabel *selectedGenreLabel = ((UILabel *)[self.genresView viewWithTag:self.page + 1]);
                if([selectedGenreLabel respondsToSelector:@selector(setTextColor:)]){
                            [((UILabel *)[self.genresView viewWithTag:self.page + 1]) setTextColor:[UIColor colorWithRed:kSelectedGenreColorR green:kSelectedGenreColorG blue:kSelectedGenreColorB alpha:1.0]];
                }
                
                
                //if there are no values, show the activity indicator
                if([[self getDataForGenre:[self getGenreForIndex:self.page]] count] == 0){
                    //add spinner activity indicator view
                    [self addActivityIndicatorToView:[self.topVideosScrollView viewWithTag:self.page + 1]];
                }
            }
    }
    
}

#pragma mark - activity indicator
//add an activity indicator to the center of the view and start animating
- (void)addActivityIndicatorToView:(UIView *)view
{
    bool hasActivityIndicator = NO;
    
    //check to see if the view already has an activity indicator
    for(UIView *object in view.subviews){
        if([object class] == [UIActivityIndicatorView class]){
            hasActivityIndicator = YES;
        }
    }
    
    //if the view doesn't have an activity indicator, add it and start animating
    if(!hasActivityIndicator){
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        [view addSubview:spinner];
        [spinner startAnimating];
    }
}

//remove the activity indicator from the view
- (void)removeActivityIndicatorFomView:(UIView *)view
{
    for(UIView *object in view.subviews){
        if([object class] == [UIActivityIndicatorView class]){
            [((UIActivityIndicatorView *)object) stopAnimating];
            [object removeFromSuperview];
        }
    }
}

#pragma mark rotation Methods
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        if([self moviePLayerOnScreen]){
            self.playerContainerView.frame =  CGRectMake(0,
                                                         0,
                                                         MAX(self.view.bounds.size.width, self.view.bounds.size.height),
                                                         MIN(self.view.bounds.size.width, self.view.bounds.size.height));
            self.playerContainerViewBackground.frame = CGRectMake(0,
                                                                  0,
                                                                  MAX(self.view.bounds.size.width, self.view.bounds.size.height),
                                                                  MIN(self.view.bounds.size.width, self.view.bounds.size.height));
            self.vodPlayer.baseView = self.playerContainerView;
        }
    }else{
        if([self moviePLayerOnScreen]){
            self.playerContainerView.frame = CGRectMake(0,
                                                           0,
                                                           MIN(self.view.bounds.size.width, self.view.bounds.size.height),
                                                           MAX(self.view.bounds.size.width, self.view.bounds.size.height) * kVideoViewHeightRatio);
            self.playerContainerViewBackground.frame = CGRectMake(0,
                                                        0,
                                                        MIN(self.view.bounds.size.width, self.view.bounds.size.height),
                                                        MAX(self.view.bounds.size.width, self.view.bounds.size.height) * kVideoViewHeightRatio);
            self.vodPlayer.baseView = self.playerContainerView;
        }
    }
}

#pragma mark - player container
//create and setup the player container
- (void)setupPlayerContainer
{
    //container view background is play, used for portrait full screen
    self.playerContainerViewBackground = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                    -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                                    self.view.frame.size.width,
                                                                                    self.view.frame.size.height * kVideoViewHeightRatio)];
    self.playerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                        -(self.view.frame.size.height * kVideoViewHeightRatio),
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height * kVideoViewHeightRatio)];
    
    self.playerContainerViewBackground.backgroundColor = [UIColor blackColor];
    self.playerContainerView.backgroundColor = [UIColor blackColor];
    self.playerContainerViewBackground.tag = 1;
    
    [self.playerContainerViewBackground addSubview:self.playerContainerView];
    [self.view addSubview:self.playerContainerViewBackground];
    
    //setup vod player
    self.vodPlayer = [[VMMoviePlayerController alloc] initWithBaseView:self.playerContainerView];
    self.vodPlayer.controlStyle = VMMovieControlStyleFullscreen;
    self.vodPlayer.containerDelegate = self;
    [self.vodPlayer playVideo:self.video];
}


#pragma mark Top bar user action Methods
- (void)playVideo:(VMVideo *)sourceVideo
{
    self.video = sourceVideo;
    [self.vodPlayer playVideo:sourceVideo];
}
- (void)stopVideo
{
    [self.vodPlayer stopPlayer];
}

-(void) onCloseButtonTapped:(id)sender
{
    [self.vodPlayer stopPlayer];
    [self removeVideoPlayer];
}

- (void) moviePlayerDidStop{}
- (void)onInfoButtonTapped:(id)sender{}
- (void)onAddButtonTapped:(id)sender{}
- (void)onShareButtonTapped:(id)sender{}
- (void)onBuyButtonTapped:(id)sender{}

#pragma mark VMMoviePlayerContainerDelegate Methods
- (void) movieplayerReadyToPlayVideo{
    TVPlayerTopBarView *topBar = [[TVPlayerTopBarView alloc] initWithFrame:CGRectMake(0, 0, self.playerContainerView.bounds.size.width, 40)];
    topBar.video = self.video;
    [_vodPlayer showOverlay:topBar];
}

- (void) movieplayerExpandButtonPressed{
    [self moviePlayerEnterFullScreen];
}

- (void) onFullScreenTapped{}
- (void) moviePlayerStartPlayingAds{

}
- (void) moviePlayerEndPlayingAds{

}

@end
