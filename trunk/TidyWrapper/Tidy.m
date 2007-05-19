//
//  Tidy.m
//  TidyWrapper
//
//  Created by Kevin Wojniak on 1/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Tidy.h"



@implementation Tidy

+ (Tidy *)tidy
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super init])
		return nil;

	_tdoc = tidyCreate();
	
	return self;
}

- (void)dealloc
{
	tidyRelease(_tdoc);

	[super dealloc];
}

- (NSString *)cleanString:(NSString *)string
{
	NSString *result = nil;
	
	const char* input = [string cStringUsingEncoding:NSUTF8StringEncoding];
	TidyBuffer output = {0};
	TidyBuffer errbuf = {0};
	int rc = -1;
	int ok;
	
	if ( ok )
		rc = tidySetErrorBuffer( _tdoc, &errbuf );      // Capture diagnostics
	if ( rc >= 0 )
		rc = tidyParseString( _tdoc, input );           // Parse the input
	if ( rc >= 0 )
		rc = tidyCleanAndRepair( _tdoc );               // Tidy it up!
	if ( rc >= 0 )
		rc = tidyRunDiagnostics( _tdoc );               // Kvetch
	if ( rc > 1 )                                    // If error, force output.
		rc = ( tidyOptSetBool(_tdoc, TidyForceOutput, yes) ? rc : -1 );
	if ( rc >= 0 )
		rc = tidySaveBuffer( _tdoc, &output );          // Pretty Print
	
	if ( rc >= 0 )
	{
		//if ( rc > 0 )
		//	printf( "\nDiagnostics:\n\n%s", errbuf.bp );
		//printf( "%s\n", output.bp );
		result = [NSString stringWithCString:(const char *)output.bp encoding:NSUTF8StringEncoding];
	}
	//else
	//	printf( "A severe error (%d) occurred.\n", rc );

	tidyBufFree(&output);
	tidyBufFree(&errbuf);
	
	return result;
}

- (void)setOutputType:(TidyOutput)output
{
	TidyOptionId opts[] = {TidyXmlOut, TidyXhtmlOut, TidyHtmlOut};
	tidyOptSetBool(_tdoc, opts[output], yes);
}

- (void)setXMLDeclaration:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyXmlDecl, flag);
}

- (void)setShowGenerator:(BOOL)flag
{
	// don't show meta generator
	tidyOptSetBool(_tdoc, TidyMark, flag);
}

- (void)setHideComments:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyHideComments, flag);
}

- (void)setShowBodyOnly:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyBodyOnly, flag);
}

- (void)setUpperCaseTags:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyUpperCaseTags, flag);
}


#pragma mark -
#pragma mark Pretty Print

- (void)setLineBreakBeforeBreakTag:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyBreakBeforeBR, flag);
}

- (void)setIndent:(BOOL)flag
{
	tidyOptSetInt(_tdoc, TidyIndentContent, flag);
}

- (void)setIndentAttributes:(BOOL)flag
{
	tidyOptSetBool(_tdoc, TidyIndentAttributes, flag);
}

- (void)setIndentSize:(int)indentSize
{
	tidyOptSetInt(_tdoc, TidyIndentSpaces, indentSize);
}



@end
