//
//  Document.h
//  iStickeez
//
//  Created by Kevin Wojniak on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StickiesDocument : NSObject
{
    NSAttributedString *attributedString;
    NSColor *color;
	NSString *title;
}

@property (readonly) NSString *title;
@property (readonly) NSAttributedString *attributedString;
@property (readonly) NSColor *color;

@end
