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


typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

//view constants
float const kTableViewCellHeightRatio       = 0.5;
float const kTableViewSectionHeightRatio    = 0.04;
float const kVideoViewHeightRatio           = 0.38;

//color constants
float const kSelectedGenreColorR = 3/255.0f;
float const kSelectedGenreColorG = 207/255.0f;
float const kSelectedGenreColorB = 235/255.0f;

#define MOVIEPLAYER_VERTICAL_HEIGHT_PAD     460
#define MOVIEPLAYER_VERTICAL_HEIGHT_PHONE   192

@interface TVMainViewController ()

@property (nonatomic) int page;
@property (nonatomic, retain) TVMovieContainerView *movieContainerView;
@property (nonatomic, retain) NSString *selectedGenre;
@property (nonatomic) int lastContentOffset;
@property (nonatomic) bool *playingAds;


@end


@implementation TVMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpened) name:@"APP_OPENED" object:nil];
    
    //set controller's init variables
    self.playingAds = NO;
    self.page = 0;
    self.selectedGenre = @"top_40_all";
    
    //hide status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    //setup scrollview
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
    [self.topVideosScrollView setShowsVerticalScrollIndicator:NO];
    [self.topVideosScrollView setShowsHorizontalScrollIndicator:NO];
    self.topVideosScrollView.bounces = NO;
    [self.topVideosScrollView setDirectionalLockEnabled:NO];
    
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
        [genreTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [genreTableView setBounces:YES];
        [genreTableView setClipsToBounds:YES];
        [genreTableView setDirectionalLockEnabled:NO];
        //add 1 to tag becuase '0' is always the superview
        genreTableView.tag = i + 1;
        
        [self.topVideosScrollView addSubview:genreTableView];
    }
    
    //set current page
    CGRect frame = self.topVideosScrollView.frame;
    frame.origin.x = frame.size.width * self.page;
    [self.topVideosScrollView scrollRectToVisible:frame animated:NO];
    
    
    //setup genre scroll view
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
        genreLabel.text = [self converKeyToValueForGenres:[APP_DELEGATE.genres objectAtIndex:i]];
        genreLabel.tag = i + 1;
        
        [self.genresView addSubview:genreLabel];
    }
    
    //add subviews
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setMultipleTouchEnabled:NO];
        [cell setExclusiveTouch:YES];
    }
    

    
    //if there are values in the array, load into tableview
    if([[APP_DELEGATE.genreData objectAtIndex:self.page] count] > 0){
            //load song dictionary
            NSDictionary *topVideo = [[APP_DELEGATE.genreData  objectAtIndex:self.page] objectAtIndex:indexPath.row];
            
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
                         
                         //shift the view frames
                         self.movieContainerView.frame = CGRectMake(0,
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
    
    
    [self.movieContainerView playVideo:video];
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
                         
                         //shift the view frames
                         self.topVideosScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [APP_DELEGATE.genres count],
                                                                           self.view.frame.size.height - (self.view.frame.size.height * kTableViewSectionHeightRatio));
                     }];
}

-(void)moviePlayerEnterFullScreen
{
    // When the cell is touched, it should faint.
    [UIView animateWithDuration:.5 animations:^{
        
        //if the player is in the center of the screen, take the view out of full screen mode
        if(self.movieContainerView.frame.size.width == [[UIScreen mainScreen]bounds].size.width && self.movieContainerView.frame.size.height == [[UIScreen mainScreen]bounds].size.height){
       //     self.playerContainerView.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
       //     self.frame = [[UIScreen mainScreen] bounds];
            self.movieContainerView.frame = CGRectMake(0,
                                                       0,
                                                       self.view.frame.size.width,
                                                       self.view.frame.size.height * kVideoViewHeightRatio);
            self.movieContainerView.playerContainerView.frame = CGRectMake(0,
                                                           0,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height * kVideoViewHeightRatio);
        }
        else{
            self.movieContainerView.playerContainerView.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
            self.movieContainerView.frame = [[UIScreen mainScreen] bounds];
        }
        
        
    }completion:^(BOOL finished){
    }];
}

#pragma mark - genre views
- (void)reloadSelectedTableViewWithCurrentGenreIndex:(int)genreIndex{
    //get list of videos from server and reload tableview when finished
    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:[APP_DELEGATE.genres objectAtIndex:self.page] offset:0 limit:kTopVideosLoadCount
                                          successBlock:^(id results){
                                              
                                              //    NSLog(@"%@",results);
                                              
                                              //set top videos dictionary and reload data
                                              [APP_DELEGATE.genreData replaceObjectAtIndex:genreIndex withObject:results];
                                              
                                              
                                              UITableView *currentTableView = (UITableView *)[self.topVideosScrollView viewWithTag:genreIndex + 1];
                                              
                                              //add 1 to tag becuase '0' is always the superview
                                              [currentTableView reloadData];
                                              
                                              //remove the activity indicator from the view
                                              [self removeActivityIndicatorFomView:currentTableView];
                                              
                                          }
                                            errorBlock:^(NSError *error){
                                                NSLog(@"%@",error);
                                            }];
}

//returns a genre that corresponds with a given index
- (NSString *)getGenreForIndex:(int)index
{
    return [APP_DELEGATE.genres objectAtIndex:index];
}


#pragma mark - other
- (void)appOpened{
    [self reloadSelectedTableViewWithCurrentGenreIndex:self.page];
}



// used for status bar preferrences
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (NSString *)converKeyToValueForGenres:(NSString *)key
{
    //@"top_40_all",@"pop",@"rbsoul",@"latino",@"metal",@"country",@"electronicdance"
    if([key isEqualToString:@"top_40_all"]){
        return @"Top 40";
    }
    else if([key isEqualToString:@"pop"]){
        return @"Pop";
    }
    else if([key isEqualToString:@"rbsoul"]){
        return @"R&B Soul";
    }
    else if([key isEqualToString:@"latino"]){
        return @"Latino";
    }
    else if([key isEqualToString:@"metal"]){
        return @"Metal";
    }
    else if([key isEqualToString:@"country"]){
        return @"Country";
    }
    else if([key isEqualToString:@"electronicdance"]){
        return @"Electronic Dance";
    }
    
    return @"";
}

- (void) moviePlayerStartPlayRecommendationAt:(int)index
{
    
    //if the app is not playing adds, allow user to select
    if(!self.playingAds){
        
        if(index <= kTopVideosLoadCount){
        
            NSString *isrcTempString = [[[APP_DELEGATE.genreData  objectAtIndex:self.page] objectAtIndex:index] valueForKey:@"isrc"];
            
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
        
        //NSLog(@"page:%d, oldPage:%d",page,self.page);
    
            //if the page has changed, move the scroll view and set page variable
            if(page != self.page){
                self.page = page;
                
                  //scroll the view
                 [scrollView scrollRectToVisible:CGRectMake((scrollView.frame.size.width * self.page),
                                                                          0,
                                                                          scrollView.frame.size.width,
                                                                          scrollView.frame.size.height) animated:YES];
                
                //load new genre
                self.selectedGenre = [APP_DELEGATE.genres objectAtIndex:self.page];
                
                //reload selected table view
                [self reloadSelectedTableViewWithCurrentGenreIndex:self.page];
                
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
                if([[APP_DELEGATE.genreData objectAtIndex:self.page] count] == 0){
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
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //[self adjustContentsLayout];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        NSLog(@" to landscape _View=%@ baseview=%@", self.view, self.movieContainerView.playerContainerView);
        self.movieContainerView.playerContainerView.frame =  CGRectMake(0, 0, MAX(self.view.bounds.size.width, self.view.bounds.size.height), MIN(self.view.bounds.size.width, self.view.bounds.size.height)); // self.view.bounds; // CGRectMake(0, 0, 1024, 720);
        self.movieContainerView.frame = CGRectMake(0, 0, MAX(self.view.bounds.size.width, self.view.bounds.size.height), MIN(self.view.bounds.size.width, self.view.bounds.size.height) );
        self.movieContainerView.vodPlayer.baseView = self.movieContainerView.playerContainerView;
        
    }else{
        int moviePlayerVerticalHeight;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            moviePlayerVerticalHeight = MOVIEPLAYER_VERTICAL_HEIGHT_PHONE;
        else
            moviePlayerVerticalHeight = MOVIEPLAYER_VERTICAL_HEIGHT_PAD;

        self.movieContainerView.playerContainerView.frame = CGRectMake(0,
                                                                       0,
                                                                       MIN(self.view.bounds.size.width, self.view.bounds.size.height),
                                                                       MAX(self.view.bounds.size.width, self.view.bounds.size.height) * kVideoViewHeightRatio);
        self.movieContainerView.frame = CGRectMake(0,
                                                   0,
                                                   MIN(self.view.bounds.size.width,self.view.bounds.size.height),
                                                   MAX(self.view.bounds.size.width, self.view.bounds.size.height) * kVideoViewHeightRatio);
        self.movieContainerView.vodPlayer.baseView = self.movieContainerView.playerContainerView;
    }
}

@end
