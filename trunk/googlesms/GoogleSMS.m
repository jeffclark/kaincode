//
//  GoogleSMS.m
//  GoogleSMS
//
//  Created by Kevin Wojniak on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GoogleSMS.h"


@implementation GoogleSMS

/*
 ACS Alaska Communications Systems
 ALLTEL Alltel
 ATT AT&amp;T (now Cingular)
 CELLULARONE CellularOne
 CINCINNATI_BELL Cincinnati Bell
 CINGULAR Cingular
 CRICKET Cricket Communications
 METROPCS MetroPCS
 MIDWEST_WIRELESS Midwest Wireless
 NEXTEL Nextel
 OMNIPOINT Omnipoint
 QWEST Qwest
 SPRINT Sprint
 SUNCOM SunCom Wireless
 TMOBILE T-Mobile
 USCELLULAR US Cellular
 <option selected=true value="VERIZON Verizon
 VIRGIN Virgin Mobile
 WESTERN_WIRELESS Western Wireless
 */

+ (void)sendMessage:(NSString *)message toPhone:(NSString *)phoneNumber forCarrier:(SMSCarrier)carrier
{
	NSString *post = [NSString stringWithFormat:@"client=navclient-ffsms&gl=US&hl=en&text=&c=1&subject=&text=testing123&send_button=Send&carrier=%@&mobile_user_id=%@",
		carrier, phoneNumber];
	
	NSURL* url = [NSURL URLWithString:@"http://www.google.com/sendtophone"];
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[post dataUsingEncoding:NSASCIIStringEncoding]];
	[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
}


@end
