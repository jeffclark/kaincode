//
//  KWUtils.h
//  Xfire
//
//  Created by Kevin Wojniak on 7/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KWUtils : NSObject
{

}

+ (int)runModalAlertWithMessage:(NSString *)message
						   text:(NSString *)infoText
				  defaultButton:(NSString *)defaultButton
			  alternativeButton:(NSString *)altButton
					otherButton:(NSString *)otherButton;

@end
