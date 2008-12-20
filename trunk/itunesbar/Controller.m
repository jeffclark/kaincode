//
//  Controller.m
//  iTunesCapacityBar
//
//  Created by Kevin Wojniak on 11/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "CapacityBar.h"


@implementation Controller

- (void)awakeFromNib
{
	[drawLinesButton setState:[capacityBar drawLines]];
	
	[self selectColor:colorsPopUp];
}

- (IBAction)addValue:(id)sender
{
	[capacityBar addValue:[valueField floatValue] forColor:[colorWell color]];
	[valueField setFloatValue:0.0];
}

- (IBAction)selectColor:(id)sender
{
	switch ([[colorsPopUp selectedItem] tag])
	{
		case 0:
			[colorWell setColor:[CapacityBar iTunesBlueColor]]; break;
		case 1:
			[colorWell setColor:[CapacityBar iTunesPurpleColor]]; break;
		case 2:
			[colorWell setColor:[CapacityBar iTunesYellowColor]]; break;
		case 3:
			[colorWell setColor:[CapacityBar iTunesOrangeColor]]; break;
	}
}

- (IBAction)clearValues:(id)sender
{
	[capacityBar clearAllValues];
}

- (IBAction)toggleVerticleLines:(id)sender
{
	[capacityBar setDrawLines:[drawLinesButton state]];
}

@end
