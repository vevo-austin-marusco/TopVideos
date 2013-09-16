//
//  CSStreamSenseMeasurement.h
//  comScore
//

// Copyright 2011 comScore, Inc. All right reserved.
//

#import <Foundation/Foundation.h>
#import "CSMeasurement.h"
#import "CSComScoreMeasurement.h"

@interface CSStreamSenseMeasurement : CSMeasurement {
	
}

-(id) initWithDax:(CSComScore *)dax;
-(id) initWithDax:(CSComScore *)dax withDictionary:(NSDictionary *) details withPixelURL:(NSString *) pixelURL;

@end
