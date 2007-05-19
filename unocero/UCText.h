//
//  UCTableView.h
//  UnoCero
//
//  Created by Kevin Wojniak on 7/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UCText : NSTextView
{
	NSCharacterSet *_allowedCharacters;
}

- (id)init;

- (NSCharacterSet *)allowedCharacters;
- (void)setAllowedCharacters:(NSCharacterSet *)allowedCharacters;

@end
