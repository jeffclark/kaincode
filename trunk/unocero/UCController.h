//
//  UCController.h
//  UnoCero
//
//  Created by Kevin Wojniak on 7/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class UCText;

@interface UCController : NSObject
{
	IBOutlet NSTextField *binTextField, *hexTextField, *octTextField, *decTextField;
	
	UCText *binEditor, *hexEditor, *octEditor, *decEditor;
}

@end
