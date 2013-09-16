//
//  CSStreamSenseClip.h
//  ComScore
//
//  Copyright (c) 2011 comScore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSStreamSenseDefines.h"
@interface CSStreamSenseClip : NSObject {
    NSMutableDictionary *_labels;
}

@property (assign) NSTimeInterval playbackTime; // ms
@property (assign) NSTimeInterval playbackTimestamp; // ms
@property (assign) NSTimeInterval bufferingTime; // ms
@property (assign) NSTimeInterval bufferingTimestamp; // ms
@property (assign) NSInteger pauses;
@property (assign) NSInteger starts;
@property (retain) NSString *clipId;

-(void) setRegisters:(NSMutableDictionary *)labels forState:(CSStreamSenseState)state;
-(void) setLabels:(NSDictionary *)newLabels forState:(CSStreamSenseState)state;
-(NSDictionary *) getLabels;
-(void) reset;
-(void) reset:(NSArray*)keepLabels;
@end
