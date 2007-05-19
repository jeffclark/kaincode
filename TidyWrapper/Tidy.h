//
//  Tidy.h
//  TidyWrapper
//
//  Created by Kevin Wojniak on 1/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <tidy.h>
#include <buffio.h>

typedef enum
{
	TidyXMLOutput,
	TidyXHTMLOutput,
	TidyHTMLOutput,
} TidyOutput;


@interface Tidy : NSObject
{
	TidyDoc _tdoc;
}

+ (Tidy *)tidy;

- (NSString *)cleanString:(NSString *)string;

// HTML, XHTML, XML Options
- (void)setOutputType:(TidyOutput)output;
- (void)setXMLDeclaration:(BOOL)flag;
- (void)setShowGenerator:(BOOL)flag;
- (void)setHideComments:(BOOL)flag;
- (void)setShowBodyOnly:(BOOL)flag;
- (void)setUpperCaseTags:(BOOL)flag;

// pretty print
- (void)setLineBreakBeforeBreakTag:(BOOL)flag;
- (void)setIndent:(BOOL)flag;
- (void)setIndentAttributes:(BOOL)flag;
- (void)setIndentSize:(int)indentSize;

@end
