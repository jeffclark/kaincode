//
//  Node.m
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@implementation Node

# pragma mark Initialization

+ (id)nodeWithParent:(Node *)node group:(BOOL)grp
{
	return [[[self alloc] initWithParent:node group:grp] autorelease];
}

- (id)initWithParent:(Node *)node group:(BOOL)grp
{
	if (self = [super init]) {
		parent = node;
		isGroup = grp;
		children = [[NSMutableArray alloc] init];
		
		return self;
	}
	
	return nil;
}

- (void)dealloc
{
	[children release];
	
	[super dealloc];
}

#pragma mark Group

- (void)setGroup:(BOOL)grp
{
	isGroup = grp;
}

- (BOOL)isGroup
{
	return isGroup;
}

# pragma mark Children

- (void)setChildren:(NSArray *)array
{
	if (!array) return;
	[children setArray:array];
}

- (NSArray *)children
{
	return [NSArray arrayWithArray:children];
}

- (int)numberOfChildren
{
	return [children count];
}

- (Node *)childAtIndex:(int)i
{
	if (i<0 || i>=[self numberOfChildren])
		return nil;
	return [children objectAtIndex:i];
}

- (int)indexOfChild:(Node *)node
{
	if (!node) return -1;
	return [children indexOfObject:node];
}

- (void)addChild:(id)node
{
	if (!node) return;
	if (![node parent]) [node setParent:self];
	[children addObject:node];

	[children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)addChildren:(NSArray *)nodes
{
	if (!nodes) return;
	[children addObjectsFromArray:nodes];

	[children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)insertChild:(Node *)node atIndex:(int)i
{
	if (!node) return;
	if (i==-1) i=0;
	[children insertObject:node atIndex:i];

	[children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)insertChildren:(NSArray *)nodes atIndex:(int)i
{
	if (!nodes) return;
	NSEnumerator *e = [nodes objectEnumerator];
	id node;
	
	NSLog(@"%@", nodes);
	
	if (i==-1) i=0;
	while (node = [e nextObject])
		[children insertObject:node atIndex:i++];
	
	[children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (void)removeAllChildren
{
	[children removeAllObjects];
}

- (void)removeChildAtIndex:(int)i
{
	[children removeObjectAtIndex:i];
}

- (void)removeChild:(Node *)node
{
	if (!node) return;
	[children removeObjectIdenticalTo:node];
}

# pragma mark Parent

- (void)setParent:(Node *)node
{
	parent = node;
}

- (Node *)parent
{
	return parent;
}

# pragma mark Sort

- (void)sort
{
	[children sortUsingSelector:@selector(compare:)];
    [children makeObjectsPerformSelector: @selector(sort)];
}

- (NSComparisonResult)compare:(Node *)other {
    return NSOrderedAscending;
}

@end
