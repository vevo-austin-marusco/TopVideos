//
//  CSStreamSenseLabels.h
//  ComScore
//
//  Copyright (c) 2011 comScore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSStreamSenseLabels : NSObject

+(NSArray *) baseMandatory;
+(NSArray *) mainMandatory;
+(NSArray *) playMandatory;
+(NSArray *) pauseMandatory;
+(NSArray *) endMandatory;
+(NSArray *) heartbeatMandatory;
+(NSArray *) playlistPlayMandatory;
+(NSArray *) playlistEndMandatory;

+(NSArray *) allMandatory;

@end
