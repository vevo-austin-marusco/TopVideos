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

@interface TVMainViewController ()

@property (nonatomic) bool playingAds;
@property (nonatomic) int page;
@property (nonatomic, retain) TVMovieContainerView *movieContainerView;
@property (nonatomic, retain) NSString *selectedGenre;
@property (nonatomic) int lastContentOffset;


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
    [self.topVideosScrollView setDirectionalLockEnabled:YES];
    
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
        [genreTableView setDirectionalLockEnabled:YES];
        //add 1 to tag becuase '0' is always the superview
        genreTableView.tag = i + 1;
        
        [self.topVideosScrollView addSubview:genreTableView];
    }
    
    //set current page
    CGRect frame = self.topVideosScrollView.frame;
    frame.origin.x = frame.size.width * [self getCurrentGenreIndex];
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

#pragma mark - other
- (void)appOpened{
    [self reloadSelectedTableViewWithCurrentGenreIndex:[self getCurrentGenreIndex]];
}

- (void)reloadSelectedTableViewWithCurrentGenreIndex:(int)genreIndex{
    //get list of videos from server and reload tableview when finished
    [[VMApiFacade sharedInstance] getTopVideosForOrder:@"" genre:[APP_DELEGATE.genres objectAtIndex:[self getCurrentGenreIndex]] offset:0 limit:kTopVideosLoadCount
                                          successBlock:^(id results){
                                              
          //    NSLog(@"%@",results);
              
              //set top videos dictionary and reload data
              [APP_DELEGATE.genreData replaceObjectAtIndex:genreIndex withObject:results];
              
              //add 1 to tag becuase '0' is always the superview
              [((UITableView *)[self.topVideosScrollView viewWithTag:genreIndex + 1]) reloadData];
              
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

//returns a genre that corresponds with a given index
- (NSString *)getGenreForIndex:(int)index
{
    return [APP_DELEGATE.genres objectAtIndex:index];
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
                [self reloadSelectedTableViewWithCurrentGenreIndex:[self getCurrentGenreIndex]];
                
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
                UILabel *selectedGenreLabel = ((UILabel *)[self.genresView viewWithTag:[self getCurrentGenreIndex] + 1]);
                if([selectedGenreLabel respondsToSelector:@selector(setTextColor:)]){
                            [((UILabel *)[self.genresView viewWithTag:[self getCurrentGenreIndex] + 1]) setTextColor:[UIColor colorWithRed:kSelectedGenreColorR green:kSelectedGenreColorG blue:kSelectedGenreColorB alpha:1.0]];
                }
                

                
            }
    }
    
}

@end
