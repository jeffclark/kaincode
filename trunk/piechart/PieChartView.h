//
//  PieChartView.h
//  PieChart
//
//  Created by Kevin Wojniak on Tue Jun 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface PieChartView : NSView {
	NSPoint centerPoint;
	int radius, rotation;
	NSString *dataString;
}

- (void)setData:(NSString *)d;
- (void)setRotation:(int)r;

- (int)totalForData:(NSArray *)d;
- (float)angleForPercent:(float)percent;
- (NSPoint)pointForAngle:(int)a;

@end
