//
//  FeedNode.m
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "FeedNode.h"


@implementation FeedNode

+ (id)nodeWithName:(NSString *)n description:(NSString *)d url:(NSString *)u link:(NSString *)l
{
	return [[[self alloc] initWithName:n description:d url:u link:l] autorelease];
}

- (id)initWithName:(NSString *)n description:(NSString *)d url:(NSString *)u link:(NSString *)l
{
	if (self = [super initWithParent:nil group:NO]) {
		name = [n retain];
		description = [d retain];
		url = [u retain];
		link = [l retain];
		return self;
	}
	
	return nil;
}

- (void)dealloc
{
	[name release];
	[description release];
	[url release];
	[link release];
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

- (void)setDescription:(NSString *)d
{
	[description release];
	description = [d retain];
}

- (NSString *)description
{
	return description;
}

- (void)setURL:(NSString *)u
{
	[url release];
	url = [u retain];
}

- (NSString *)url
{
	return url;
}

- (void)setLink:(NSString *)l
{
	[link release];
	link = [l retain];
}

- (NSString *)link
{
	return link;
}

- (NSComparisonResult)compare:(FeedNode *)other
{
    return [name caseInsensitiveCompare:[(FeedNode *)other name]];
}

@end
