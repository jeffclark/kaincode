#import <Adium/AIAccount.h>
#import "Xfire.h"

@interface KWXfireAccount : AIAccount <XfireDelegate>
{
	Xfire *_xfire;
	
	NSDate *_connectDate;

	NSMutableArray *_invites;
}

@end
