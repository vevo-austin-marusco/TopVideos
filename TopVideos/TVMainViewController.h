//
//  VMViewController.h
//  TopVideos
//
//  Created by New Admin User on 9/3/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVMainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    NSMutableDictionary *topVideos;
}

@property (nonatomic,retain) UITableView *tableView;

@end
