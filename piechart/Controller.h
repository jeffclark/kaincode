//
//  Controller.h
//  PieChart
//
//  Created by Kevin Wojniak on Tue Jun 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieChartView.h"

@interface Controller : NSObject {
	IBOutlet PieChartView *pieChart;
	IBOutlet NSTextField *dataField;
}

- (IBAction)setData:(id)sender;
- (IBAction)setRotation:(id)sender;

- (float)totalSpace:(NSString*)path;
- (float)freeSpace:(NSString*)path;

@end
