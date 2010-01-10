//
//  BOAppController.m
//  BootChamp
//
//  Created by Kevin Wojniak on 7/6/08.
//  Copyright 2008-2010 Kevin Wojniak. All rights reserved.
//

#import "BOAppController.h"
#import "BOStatusMenuController.h"
#import "BOBoot.h"


@implementation BOAppController

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	m_statusController = [[BOStatusMenuController alloc] init];
}

@end
