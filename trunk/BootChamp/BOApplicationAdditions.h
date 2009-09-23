//
//  BOApplicationAdditions.h
//  BootChamp
//
//  Created by Kevin Wojniak on 9/3/09.
//  Copyright 2009 Kainjow LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (BOApplicationAdditions)

- (void)addToLoginItems;
- (void)removeFromLoginItems;

@end
