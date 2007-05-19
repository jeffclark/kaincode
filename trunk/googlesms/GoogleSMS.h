//
//  GoogleSMS.h
//  GoogleSMS
//
//  Created by Kevin Wojniak on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NSString* SMSCarrier;
const SMSCarrier gACS = @"ACS";
const SMSCarrier gAlltel = @"ALLTEL";
const SMSCarrier gATT = @"ATT";
const SMSCarrier gCellularOne = @"CELLULARONE";
const SMSCarrier gCincinnatiBell = @"CINCINNATI_BELL";
const SMSCarrier gCingular = @"CINGULAR";
const SMSCarrier gCricketCommunications = @"CRICKET";
const SMSCarrier gMetroPCS = @"METROPCS";
const SMSCarrier gMidwestWireless = @"MIDWEST_WIRELESS";
const SMSCarrier gNextel = @"NEXTEL";
const SMSCarrier gOmnipoint = @"OMNIPOINT";
const SMSCarrier gQwest = @"QWEST";
const SMSCarrier gSprint = @"SPRINT";
const SMSCarrier gSunComWireless = @"SUNCOM";
const SMSCarrier gTMobile = @"TMOBILE";
const SMSCarrier gUSCellular = @"USCELLULAR";
const SMSCarrier gVerizon = @"VERIZON";
const SMSCarrier gVirginMobile = @"VIRGIN";
const SMSCarrier gWesternWireless = @"WESTERN_WIRELESS";


@interface GoogleSMS : NSObject
{

}

+ (void)sendMessage:(NSString *)message toPhone:(NSString *)phoneNumber forCarrier:(SMSCarrier)carrier;

@end
