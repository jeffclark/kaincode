//
//  MLMenuSorter.h
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenuItem (MLMenuSorter)
- (NSComparisonResult)compare:(id)menuItem;
@end


@interface NSMenu (MLMenuSorter)
- (void)sortItemsByTitle;
- (id)itemWithRepresentedString:(NSString *)str;
- (void)removeAllItems;
- (id <NSMenuItem>)addItemWithTitle:(NSString *)aString target:(id)aTarget action:(SEL)aSelector;
@end
