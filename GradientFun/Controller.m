//
//  Controller.m
//  GradientFun
//
//  Created by Kevin Wojniak on 9/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "GradientView.h"


@implementation Controller

- (void)update
{
	NSMutableAttributedString *astr = [[[NSMutableAttributedString alloc] initWithString:[textField stringValue]] autorelease];
	NSArray *colors = [gradientView gradientComponentsForStartingColor:[w1 color]
														andEndingColor:[w2 color]
																 count:[astr length]];
	unsigned ch = 0;
	for (ch=0; ch<[astr length]; ch++)
	{
		NSColor *color = [colors objectAtIndex:ch];
		[astr setAttributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]
					  range:NSMakeRange(ch, 1)];
	}
	[[astr RTFFromRange:NSMakeRange(0, [astr length]) documentAttributes:nil] writeToFile:@"/Users/kainjow/Desktop/test.rtf" atomically:YES];
	[textField setAttributedStringValue:astr];
}

- (IBAction)color:(id)sender
{
	if (sender == w1)
		gradientView.startColor = [sender color];
	else
		gradientView.endColor = [sender color];
	[self update];
}

- (void)awakeFromNib
{
	gradientView.startColor = [w1 color];
	gradientView.endColor = [w2 color];
	[self update];
}

@end
