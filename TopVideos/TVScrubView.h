//
//  TVScrubView.h
//  TopVideos
//
//  Created by New Admin User on 9/5/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol TVScrubViewDelegate;

@interface TVScrubView : UIView
{
	UILabel *tickLabel;
	UIView *bufferView;
    BOOL hideTickLabel;
@private
	BOOL pressed;
	NSTimeInterval newPlaybackTime;
}

@property (nonatomic, weak) id  <TVScrubViewDelegate> delegate;
@property (nonatomic) NSTimeInterval totalTime;

- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (void)setBufferBar:(NSTimeInterval)from :(NSTimeInterval)to;

@end

@protocol TVScrubViewDelegate
- (void)setNewPlaybackTime:(NSTimeInterval)newPlaybackTime;
- (void)updateTimeLabel:(NSTimeInterval)currentTime;
- (void)pauseTimer;
- (void)resumeTimer;
@end

