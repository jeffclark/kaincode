//
//  FeedNode.h
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface FeedNode : Node {

	NSString *name, *description, *url, *link;
}

+ (id)nodeWithName:(NSString *)n description:(NSString *)d url:(NSString *)u link:(NSString *)l;
- (id)initWithName:(NSString *)n description:(NSString *)d url:(NSString *)u link:(NSString *)l;

- (void)setName:(NSString *)n;
- (NSString *)name;

- (void)setDescription:(NSString *)d;
- (NSString *)description;

- (void)setURL:(NSString *)u;
- (NSString *)url;

- (void)setLink:(NSString *)l;
- (NSString *)link;

- (NSComparisonResult)compare:(FeedNode *)other;

@end
