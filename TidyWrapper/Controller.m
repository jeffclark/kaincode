//
//  Controller.m
//  TidyWrapper
//
//  Created by Kevin Wojniak on 1/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "Tidy.h"

@implementation Controller

- (void)awakeFromNib
{
	Tidy *tidy = [Tidy tidy];
	NSString *inputHTML = @"<b>hello!<p class='bob'>HI</b><table><u>hello my name is john.<br><!--a comment!!!-->";
	NSString *outputHTML = nil;
	
	[tidy setOutputType:TidyXHTMLOutput];
	//[tidy setXMLDeclaration:YES];
	[tidy setShowGenerator:NO];
	//[tidy setHideComments:NO];
	//[tidy setShowBodyOnly:YES];
	[tidy setUpperCaseTags:NO];
	[tidy setIndent:YES];
	[tidy setIndentAttributes:YES];
	[tidy setLineBreakBeforeBreakTag:YES];
	
	outputHTML = [tidy cleanString:inputHTML];
	NSLog(outputHTML);
	
	
	[NSApp terminate:nil];
}

@end
