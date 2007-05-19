//
//  MLDeliciousAccount.m
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MLDeliciousAccount.h"
#import "defines.h"


@implementation MLDeliciousAccount

+ (id)sharedAccount
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (self = [super init])
	{
		NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[[NSURL URLWithString:kDEFAULT_API_URL] host]
																					   port:0
																				   protocol:@"http"
																					  realm:kDEFAULT_SECURITY_DOMAIN
																	   authenticationMethod:NSURLAuthenticationMethodDefault] autorelease];
		
		NSURLCredential *credentials = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
		if (credentials)
		{
			_username = [[credentials user] copy];
			_password = [[credentials password] copy];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_username release];
	[_password release];
	[super dealloc];
}

- (NSString *)username
{
	return [[_username copy] autorelease];
}

- (NSString *)password
{
	return [[_password copy] autorelease];
}

- (void)setUsername:(NSString *)username password:(NSString *)password
{
	NSURLCredential *credential = [NSURLCredential credentialWithUser:username
															 password:password
														  persistence:NSURLCredentialPersistencePermanent];
	NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[[NSURL URLWithString:kDEFAULT_API_URL] host]
																				   port:0
																			   protocol:@"http"
																				  realm:kDEFAULT_SECURITY_DOMAIN
																   authenticationMethod:NSURLAuthenticationMethodDefault] autorelease];
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
														forProtectionSpace:protectionSpace];
	
	if (_username != username)
	{
		[_username release];
		_username = [username copy];
	}

	if (_password != password)
	{
		[_password release];
		_password = [password copy];
	}
}

@end
