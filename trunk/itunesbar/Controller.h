//
//  Controller.h
//  iTunesCapacityBar
//
//  Created by Kevin Wojniak on 11/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CapacityBar;

@interface Controller : NSObject
{
	IBOutlet CapacityBar *capacityBar;
	IBOutlet NSTextField *valueField;
	IBOutlet NSColorWell *colorWell;
	IBOutlet NSButton *drawLinesButton;
	IBOutlet NSPopUpButton *colorsPopUp;
}

- (IBAction)addValue:(id)sender;
- (IBAction)selectColor:(id)sender;
- (IBAction)clearValues:(id)sender;
- (IBAction)toggleVerticleLines:(id)sender;

@end
