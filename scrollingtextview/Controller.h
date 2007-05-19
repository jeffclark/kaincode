//
//  Controller.h
//  ScrollingTextView
//
//  Created by Kevin Wojniak on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KWScrollingTextView;

@interface Controller : NSObject
{
	IBOutlet KWScrollingTextView *textView;
	
	IBOutlet NSMenuItem *menuItem;
}

@end
