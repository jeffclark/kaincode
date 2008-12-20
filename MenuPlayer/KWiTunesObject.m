//
//  KWiTunesObject.m
//  MenuPlayer
//
//  Created by Kevin Wojniak on 3/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWiTunesObject.h"


@implementation KWiTunesObject

@synthesize name = m_name;

- (id)init
{
	if (self = [super init])
	{
		self.name = nil;
	}
	
	return self;
}

- (void)dealloc
{
	self.name = nil;
	[super dealloc];
}

@end
