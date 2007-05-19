//
//  FeedGroupNode.m
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "GroupNode.h"


@implementation GroupNode

+ (id)nodeWithName:(NSString *)n
{
	return [[[self alloc] initWithName:n] autorelease];
}

- (id)initWithName:(NSString *)n
{
	if (self = [super initWithParent:nil group:YES]) {
		name = [n retain];
		return self;
	}
	
	return nil;
}

- (void)dealloc
{
	[name release];
	[super dealloc];
}

- (void)setName:(NSString *)n
{
	[name release];
	name = [n retain];
}

- (NSString *)name
{
	return name;
}

- (int)totalNumberOfChildren
{
	NSEnumerator *e = [[self children] objectEnumerator];
	id node;
	int c=0;
	while (node = [e nextObject]) {
		if ([node isGroup])
			c+=[node totalNumberOfChildren];
		else
			c++;
	}
	return c;
}

- (NSComparisonResult)compare:(GroupNode *)other
{
    return [name caseInsensitiveCompare:[(GroupNode *)other name]];
}

@end
