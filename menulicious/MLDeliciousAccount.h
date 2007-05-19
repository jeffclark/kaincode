//
//  MLDeliciousAccount.h
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MLDeliciousAccount : NSObject 
{
	NSString *_username, *_password;
}

+ (id)sharedAccount;

- (NSString *)username;
- (NSString *)password;

- (void)setUsername:(NSString *)username password:(NSString *)password;

@end
