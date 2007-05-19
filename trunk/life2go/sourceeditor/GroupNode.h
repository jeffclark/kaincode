//
//  FeedGroupNode.h
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface GroupNode : Node {
	NSString *name;
}

+ (id)nodeWithName:(NSString *)n;
- (id)initWithName:(NSString *)n;

- (void)setName:(NSString *)n;
- (NSString *)name;

- (int)totalNumberOfChildren;

- (NSComparisonResult)compare:(GroupNode *)other;

@end
