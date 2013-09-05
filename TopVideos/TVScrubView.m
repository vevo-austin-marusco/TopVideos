//
//  TVScrubView.m
//  TopVideos
//
//  Created by New Admin User on 9/5/13.
//  Copyright (c) 2013 Vevo. All rights reserved.
//


#import "TVScrubView.h"
//#import "NSString+VMExtras.h"
//#import "VMDDLog.h"
#import <QuartzCore/QuartzCore.h>

@implementation TVScrubView
{
    CGFloat mBufferStartX, mBufferEndX;
    CGFloat mPlayheadX;
}

#define TICKLABEL_WIDTH 50
#define TICKLABEL_HEIGHT 10
#define TICKLABEL_BOTTOM_PADDING 5

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	if (isnan(_totalTime)) return;
    
    if (isnan(currentTime)) return;
	//VMDDLogVerbose(@"currentTime=%f, totalTime=%f ", currentTime, _totalTime);
	// this seems to happen sometimes where current time is larger than total time
	if (currentTime > _totalTime) {
		currentTime = _totalTime;
	}
    
    CGFloat x = 0.0f;
    if (_totalTime > 0) {
        x = floorf((self.bounds.size.width - [self playheadWidth]) * (currentTime / _totalTime));
    }
    //VMDDLogVerbose(@"x=%f ", x);
    mPlayheadX = x;
    
    if (!hideTickLabel) {
        x = x - (TICKLABEL_WIDTH - [self playheadWidth]) / 2;
        tickLabel.frame = CGRectMake(x, (self.bounds.size.height/2.0f) - ([self playheadHeight]/2.0f) -  TICKLABEL_HEIGHT - 2.0f, tickLabel.frame.size.width, tickLabel.frame.size.height);
        //tickLabel.text = [NSString vm_formattedTimeFromInterval:currentTime];
        int minutes = floor(((double)currentTime / 60.0));
        int seconds = floor((double)currentTime - (60 * minutes));
        
        tickLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", minutes, seconds];
    }
    //VMDDLogVerbose(@"x=%f ", x);
    
    [self setNeedsDisplay];
	[self.delegate updateTimeLabel:currentTime];
    //VMDDLogVerbose(@"x=%f ", x);
}

- (void)setBufferBar:(NSTimeInterval)from :(NSTimeInterval)to {
	if (isnan(from) || isnan(to) || from == -1.0f) {
		bufferView.frame = CGRectZero;
		return;
	}
	
    if (isnan(_totalTime) || _totalTime == 0)
    {
        bufferView.frame = CGRectZero;
        return;
    }
    
	float from_x = ceil(self.bounds.size.width * (from / _totalTime));
	float to_x = ceil(self.bounds.size.width * (to / _totalTime));
    
    mBufferStartX = from_x;
    mBufferEndX = to_x;
	
	bufferView.frame = CGRectMake(from_x, 0, to_x - from_x, 40);
    
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];// colorWithWhite:0.0f alpha:0.5f];
        mBufferStartX = mBufferEndX = 0.0f;
        mPlayheadX = 0.0f;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    if (!isnan(_totalTime)) {
		
        if (!hideTickLabel && !tickLabel) {
            CGRect tickLabelFrame = CGRectMake(mPlayheadX - (TICKLABEL_WIDTH - [self playheadWidth]) / 2, (self.bounds.size.height/2.0f) - ([self playheadHeight]/2.0f) -  TICKLABEL_HEIGHT - 2.0f, TICKLABEL_WIDTH, TICKLABEL_HEIGHT);
            tickLabel = [[UILabel alloc] initWithFrame:tickLabelFrame];
            tickLabel.font = [UIFont boldSystemFontOfSize:9.0];
            tickLabel.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter;
            tickLabel.textColor = [UIColor whiteColor];
            tickLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0f];
            
            int minutes = floor(((double)0 / 60.0));
            int seconds = floor((double)0 - (60 * minutes));
            tickLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", minutes, seconds];
            [self addSubview:tickLabel];
		}
	}
}

- (void)drawRect:(CGRect)rect
{
    // Add a clip path.
    CGFloat hOver2 = self.bounds.size.height / 2.0f;
    CGFloat barHeightOver2 = [self barHeight] / 2.0f;
    
    // Draw the bar time bar.
    CGRect barRect;
    barRect.origin.x = 0.0f;
    barRect.origin.y = hOver2 - barHeightOver2;
    barRect.size.width = self.bounds.size.width;
    barRect.size.height = barHeightOver2 * 2.0f;
    UIBezierPath *barPath = [UIBezierPath bezierPathWithRoundedRect:barRect cornerRadius:barHeightOver2];
    [[UIColor colorWithWhite:0.1f alpha:1.0f] setFill];
    [barPath fill];
    
    // Draw the buffering section.
    CGRect bufferRect;
    bufferRect.origin.x = mBufferStartX;
    bufferRect.origin.y = hOver2 - barHeightOver2;
    bufferRect.size.width = mBufferEndX - mBufferStartX;
    bufferRect.size.height = barHeightOver2 * 2.0f;
    UIBezierPath *bufferPath = [UIBezierPath bezierPathWithRoundedRect:bufferRect cornerRadius:[self cornerRadius]];
    [[UIColor whiteColor] setFill];
    [bufferPath fill];
    
    // Draw the playhead.
    CGFloat playheadWidth = [self playheadWidth];
    CGFloat playheadHeightOver2 = [self playheadHeight] / 2.0f;
    CGRect playheadRect;
    playheadRect.origin.x = mPlayheadX;
    playheadRect.origin.y = hOver2 - playheadHeightOver2;
    playheadRect.size.width = playheadWidth;
    playheadRect.size.height = playheadHeightOver2 * 2.0f;
    UIBezierPath *playheadPath = [UIBezierPath bezierPathWithRoundedRect:playheadRect cornerRadius:playheadWidth/2.0f];
    [[UIColor darkGrayColor] setFill];
    [playheadPath fill];
}

- (CGFloat)cornerRadius
{
    return [self barHeight] / 2.0f;
}

- (CGFloat)barHeight
{
    return 5.0f;
}

- (CGFloat)playheadWidth
{
    return 5.0f;
}

- (CGFloat)playheadHeight
{
    return 8.0f;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	pressed = YES;
    //VMDDLogVerbose(@"touchesBegin");
	[self.delegate pauseTimer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
	
	float x = currentTouchPosition.x - ceil([self playheadWidth] / 2);
	if (x < 0) x = 0;
	if (x > self.frame.size.width - [self playheadWidth]) x = self.frame.size.width - [self playheadWidth];
	
	newPlaybackTime = x * _totalTime / (self.bounds.size.width - [self playheadWidth]);
	
    //VMDDLogVerbose(@"touchesMoved setCurrentTime");
    [self setCurrentTime:newPlaybackTime];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	pressed = NO;
    
    
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
	float x = currentTouchPosition.x - ceil([self playheadWidth] / 2);
    //VMDDLogVerbose(@"x=%f playheadwidth=%f, currentTouchPositionX=%f", x, [self playheadWidth], currentTouchPosition.x);
	if (x < 0) x = 0;
	if (x > self.frame.size.width - [self playheadWidth]) x = self.frame.size.width - [self playheadWidth];
	//VMDDLogVerbose(@"x=%f playheadwidth=%f", x, [self playheadWidth]);
	newPlaybackTime = x * _totalTime / (self.bounds.size.width - [self playheadWidth]);
	[self.delegate setNewPlaybackTime:newPlaybackTime];
    
    [self.delegate resumeTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	pressed = NO;
	[self.delegate resumeTimer];
	[self.delegate setNewPlaybackTime:newPlaybackTime];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView commitAnimations];
}


@end

