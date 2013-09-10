//
//  VMViewController.h
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVMainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIScrollViewDelegate>

@property (nonatomic,retain) UIScrollView *genresView;
@property (nonatomic,retain) UIScrollView *topVideosScrollView;

@end
