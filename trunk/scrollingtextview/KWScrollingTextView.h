//
//  KWScrollingTextView.h
//  ScrollingTextView
//
//  Created by Kevin Wojniak on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KWScrollingTextView : NSTextView
{
	int _kwScrollPosition;
}

- (void)startScrollingWithInitialDelay:(NSTimeInterval)delay;

@end
