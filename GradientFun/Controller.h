//
//  Controller.h
//  GradientFun
//
//  Created by Kevin Wojniak on 9/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GradientView;

@interface Controller : NSObject
{
	IBOutlet GradientView *gradientView;
	IBOutlet NSTextField *textField;
	IBOutlet NSColorWell *w1, *w2;
}

- (IBAction)color:(id)sender;

@end
