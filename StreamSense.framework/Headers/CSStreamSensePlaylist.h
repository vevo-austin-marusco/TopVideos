//
//  CSStreamSensePlaylist.h
//  ComScore
//
//  Copyright (c) 2011 comScore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSStreamSenseClip.h"
#import "CSStreamSenseDefines.h"

@interface CSStreamSensePlaylist : NSObject {
    NSMutableDictionary *_labels;
}

-(void) reset;
-(void) reset:(NSArray*)keepLabels;
-(void) setRegisters:(NSMutableDictionary *)labels forState:(CSStreamSenseState)state;
-(void) setLabels:(NSDictionary *)newLabels forState:(CSStreamSenseState)state;
-(NSDictionary *) getLabels;

@property (retain) NSString *playlistId;
@property (assign) NSInteger pauses;
@property (assign) NSInteger starts;
@property (assign) NSInteger rebufferCount;
@property (assign) NSInteger setPlaylistCounter;
@property (assign) NSTimeInterval bufferingTime; // ms
@property (assign) NSTimeInterval playbackTime; // ms
@property (assign) NSInteger firstPlayOccurred;

@end
