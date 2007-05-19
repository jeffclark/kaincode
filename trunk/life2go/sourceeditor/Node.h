//
//  Node.h
//  Pod2Go Source Editor
//
//  Created by Kevin Wojniak on Sat Jul 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Node : NSObject {

	NSMutableArray *children;
	Node *parent;
	
	BOOL isGroup;
}

+ (id)nodeWithParent:(Node *)node group:(BOOL)grp;
- (id)initWithParent:(Node *)node group:(BOOL)grp;

- (void)setGroup:(BOOL)grp;
- (BOOL)isGroup;

- (void)setChildren:(NSArray *)array;
- (NSArray *)children;

- (int)numberOfChildren;
- (Node *)childAtIndex:(int)i;
- (int)indexOfChild:(Node *)node;

- (void)addChild:(id)node;
- (void)addChildren:(NSArray *)nodes;
- (void)insertChild:(Node *)node atIndex:(int)i;
- (void)insertChildren:(NSArray *)nodes atIndex:(int)i;

- (void)removeAllChildren;
- (void)removeChildAtIndex:(int)i;
- (void)removeChild:(Node *)node;

- (void)setParent:(Node *)node;
- (Node *)parent;

- (void)sort;

@end
