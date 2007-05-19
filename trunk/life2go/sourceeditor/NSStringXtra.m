#import "NSStringXtra.h"

@implementation NSString (NSStringXtra)

- (NSString *) trimWhiteSpace {

    NSMutableString *s = [[self mutableCopy] autorelease];

    CFStringTrimWhitespace ((CFMutableStringRef) s);

    return (NSString *) [[s copy] autorelease];
} /*trimWhiteSpace*/


- (NSString *) ellipsizeAfterNWords: (int) n {

    NSArray *stringComponents = [self componentsSeparatedByString: @" "];
    NSMutableArray *componentsCopy = [stringComponents mutableCopy];
    int ix = n;
    int len = [componentsCopy count];

    if (len < n)
        ix = len;

    [componentsCopy removeObjectsInRange: NSMakeRange (ix, len - ix)];

    return [componentsCopy componentsJoinedByString: @" "];
} /*ellipsizeAfterNWords*/

- (NSString *)stripHTML
{
	NSString *str = [NSString stringWithString:self];
	NSBundle *framework = [NSBundle bundleWithPath:[[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"Pod2Go.framework"]];

	if (framework) {
		NSTask *task;
		NSPipe *inPipe=[NSPipe pipe], *outPipe=[NSPipe pipe];
		NSFileHandle *inHandle=[inPipe fileHandleForWriting], *outHandle=[outPipe fileHandleForReading];
		NSData *writeData=[str dataUsingEncoding:NSUTF8StringEncoding], *readData;
		NSString *output;
		NSString *path = [framework pathForResource:@"striphtml" ofType:@"pl"];

		if (path!=nil && writeData!=nil) {
			task = [[NSTask alloc] init];
			[task setLaunchPath:path];
			[task setStandardOutput:outPipe];
			[task setStandardError:outPipe];
			[task setStandardInput:inPipe];
			//[task launch];
			[task performSelectorOnMainThread:@selector(launch) withObject:nil waitUntilDone:YES];
			[inHandle writeData:writeData];
			[inHandle closeFile];
			
			readData = [outHandle readDataToEndOfFile];
			
			//[task waitUntilExit];
			[task performSelectorOnMainThread:@selector(waitUntilExit) withObject:nil waitUntilDone:YES];
			[task release];
			
			if (readData && [readData length]) {
				output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
				if (output)
					return [output autorelease];
			}
		}
	}
	
	return str;
}

- (NSString *)stripHTMLSimple
{
	int len = [self length];
	NSMutableString *s = [NSMutableString stringWithCapacity:len];
	int i = 0, level = 0;
	
	for (i=0; i<len; i++) {
		NSString *ch = [self substringWithRange: NSMakeRange (i, 1)];
		
		if ([ch isEqualTo: @"<"])
			level++;
		else if ([ch isEqualTo: @">"]) {
			level--;
			
			if (level == 0)			
				[s appendString: @" "];
		}
		else if (level == 0)			
			[s appendString: ch];
	}
	
	return [[s copy] autorelease];
}	

+ (BOOL) stringIsEmpty: (NSString *) s {

    NSString *copy;

    if (s == nil)
        return (YES);

    if ([s isEqualTo: @""])
        return (YES);

    copy = [[s copy] autorelease];

    if ([[copy trimWhiteSpace] isEqualTo: @""])
        return (YES);

    return (NO);
} /*stringIsEmpty*/


- (NSString *)removeWhiteSpace:(NSArray *)w // aka removeWhiteSpace
{
    NSMutableString *new = [NSMutableString string];
    NSArray *whites;
    NSEnumerator *e;
    id item;

    if (!w)
        whites = [NSArray arrayWithObjects:@"\r", @"\n", @"\t", nil];
    else
        whites = w;
    e = [whites objectEnumerator];
    
    [new setString:[[self mutableCopy] autorelease]];
    
    while (item = [e nextObject]) {
        NSRange r = [new rangeOfString:item];

        while (r.location != NSNotFound) {
            [new replaceOccurrencesOfString:item withString:@"" options:nil range:NSMakeRange(0, [new length])];
            r = [new rangeOfString:item];
        }
    }
    
    while ([new replaceOccurrencesOfString:@"  "
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [new length])]);
    
    return new;
}

- (NSString *)makeHTMLReadable:(NSString *)fromString
{
    NSMutableString *readable = [NSMutableString string];
    NSArray *body;

	[readable setString:self];
	
	if (fromString != nil)
		if ([readable containsString:fromString]) {
			NSRange r = [readable rangeOfString:fromString];
			[readable setString:[readable substringFromIndex:r.location]];
		}

	[readable setString:[readable removeWhiteSpace:nil]]; // removes double spaces

	body = [readable componentsSeparatedByString:@"<body"];
	if ([body count]==1)
		body = [readable componentsSeparatedByString:@"<BODY"];
	if ([body count]==2) {
		NSMutableArray *body2 = [NSMutableArray array];
		[body2 setArray:[[body objectAtIndex:1] componentsSeparatedByString:@">"]];
		if ([body2 count]>1) {
			[body2 removeObjectAtIndex:0];
			[readable setString:[body2 componentsJoinedByString:@">"]];
		}
	}
	
	[readable setString:[readable removeEntities]];
	[readable setString:[readable replace:@"\n " with:@"\r"]];
	[readable setString:[readable replace:@"\r " with:@"\r"]];
    [readable setString:[readable replace:@"<tr>" with:@"\r"]];
    [readable setString:[readable replace:@"<p" with:@"\r\r<"]];
    [readable setString:[readable replace:@"<P" with:@"\r\r<"]];
    [readable setString:[readable replace:@"<hr>" with:@"\r---------------\r"]];
    [readable setString:[readable replace:@"<br" with:@"\r<"]];
    [readable setString:[readable replace:@"<BR" with:@"\r<"]];
    [readable setString:[readable removeScriptTags]]; // remove <script> things
	[readable setString:[[readable stripHTML] removeWhiteSpace:[NSArray array]]];
	[readable setString:[readable removeExtraLines]];
    [readable setString:[readable trimWhiteSpace]];

    return readable;
}

- (NSString *)removeScriptTags
{
	NSString *str = [NSString stringWithString:self];
	NSBundle *framework = [NSBundle bundleWithPath:[[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"Pod2Go.framework"]];
	
	if (framework) {
		NSTask *task;
		NSPipe *inPipe=[NSPipe pipe], *outPipe=[NSPipe pipe];
		NSFileHandle *inHandle=[inPipe fileHandleForWriting], *outHandle=[outPipe fileHandleForReading];
		NSData *writeData=[str dataUsingEncoding:NSUTF8StringEncoding], *readData;
		NSString *output;
		NSString *path = [framework pathForResource:@"stripscripttag" ofType:@"pl"];
		
		if (path) {
			task = [[NSTask alloc] init];
			[task setLaunchPath:path];
			[task setStandardOutput:outPipe];
			[task setStandardError:outPipe];
			[task setStandardInput:inPipe];
			//[task launch];
			[task performSelectorOnMainThread:@selector(launch) withObject:nil waitUntilDone:YES];
			[inHandle writeData:writeData];
			[inHandle closeFile];
			
			readData = [outHandle readDataToEndOfFile];
			
			//[task waitUntilExit];
			[task performSelectorOnMainThread:@selector(waitUntilExit) withObject:nil waitUntilDone:YES];
			[task release];
			
			if (readData && [readData length]) {
				output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
				if (output) {
					return [output autorelease];
				}
			}
		}
	}
	
	return str;
}

- (NSString *)removeExtraLines
{
	NSMutableString *new = [NSMutableString string];
	[new setString:self];
	
	[new setString:[new replace:@"\n" with:@"\r"]];
	while ([new replaceOccurrencesOfString:@"\r " withString:@"\r" options:NSLiteralSearch range:NSMakeRange(0, [new length])]);	
	while ([new replaceOccurrencesOfString:@"\r\r\r" withString:@"\r\r" options:NSLiteralSearch range:NSMakeRange(0, [new length])]);	
	
	return new;
}

- (NSString *)removeEntities
{
	NSMutableString *new = [NSMutableString string];
	[new setString:self];
	
	[new setString:[new replace:@"&nbsp;" with:@" "]];
	[new setString:[new replace:@"&apos;" with:@"'"]];
	[new setString:[new replace:@"&#039;" with:@"'"]];
	[new setString:[new replace:@"&#39;" with:@"'"]];
	[new setString:[new replace:@"&#34;" with:@"\""]];
	[new setString:[new replace:@"&#151;" with:@"-"]];
	[new setString:[new replace:@"&quote;" with:@"\""]];
	[new setString:[new replace:@"&quot;" with:@"\""]];
	[new setString:[new replace:@"&copy;" with:@"©"]];
	[new setString:[new replace:@"&lt;" with:@"<"]];
	[new setString:[new replace:@"&gt;" with:@">"]];
	[new setString:[new replace:@"&amp;" with:@"&"]];
	[new setString:[new replace:@"&raquo;" with:@"È"]];
	[new setString:[new replace:@"&deg;" with:@"û"]];
	[new setString:[new replace:@"&middot;" with:@"¥"]];

	return new;
}

- (NSString *)replace:(NSString *)str1 with:(NSString *)str2
{
    NSMutableString *new = [NSMutableString string];
    NSRange r;
    
    [new setString:[[self mutableCopy] autorelease]];

    do {
        r = [new rangeOfString:str1];
        [new replaceOccurrencesOfString:str1 withString:str2 options:nil range:NSMakeRange(0, [new length])];
    } while (r.location != NSNotFound);
    
    return new;
}

- (NSString *)removeNumberOfPathComponents:(int)number
{
    int i;
    NSMutableString *s = [NSMutableString string];
    
    [s setString:self];
    
    for (i=0; i<number; i++)
        [s setString:[s stringByDeletingLastPathComponent]];
    
    return s;
}

- (NSString *)wordsUpTo:(int)length
{
	if ([self length] <= length)
		return self;
	
	NSMutableString *new = [NSMutableString string];
	NSArray *words = [[self correctFilename] componentsSeparatedByString:@" "];
	int i;
	
	for (i=0; i<[words count]; i++) {
		NSString *proposed = [new stringByAppendingString:[NSString stringWithFormat:@" %@", [words objectAtIndex:i]]];
		if ([[proposed trimWhiteSpace] length]<=length) {
			[new appendFormat:@" %@", [words objectAtIndex:i]];
		}
	}
	
	return [new trimWhiteSpace];
}

- (NSString *)correctFilename
{
	NSMutableString *s = [NSMutableString string];
	[s setString:self];
	
	[s setString:[s replace:@"/" with:@"-"]];
	[s setString:[s replace:@":" with:@"-"]];
	//[s setString:[s replace:@"." with:@""]];
	
	return s;
}

- (NSString *)removeCdataStuff
{
	NSMutableString *s = [NSMutableString string];
	NSString *str1, *str2;
	
	str1 = @"<![CDATA[";
	str2 = @"]]>";
	
	[s setString:self];
	
	if ([s containsString:str1] && [s containsString:str2]) {
		[s setString:[s replace:str1 with:@""]];
		[s setString:[s replace:str2 with:@""]];
	}
	
	return s;
}

- (BOOL)containsString:(NSString *)aString
{
    unsigned mask = NSCaseInsensitiveSearch;
    NSRange range = [self rangeOfString:aString options:mask];
    return (range.length > 0);
}

- (NSString *)URLSafe
{
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8);
}

- (NSString *)reverseString
{
	NSMutableString *new = [NSMutableString string];
	int i;
	for (i=0; i<[self length]; i++) {
		[new insertString:[self substringWithRange:NSMakeRange(i, 1)] atIndex:0];
	}
	
	return new;
}

- (NSString *)cleanForXML
{
	NSMutableString *str = [NSMutableString string];
	[str setString:self];
	
	//[str setString:[str replace:@"&" with:@"&amp;"]];
	[str replaceOccurrencesOfString:@"&" withString:@"&amp;" options:nil range:NSMakeRange(0, [str length])];
	
	[str setString:[str replace:@"<" with:@"&lt;"]];
	[str setString:[str replace:@">" with:@"&gt;"]];
	[str setString:[str replace:@"'" with:@"&apos;"]];
	[str setString:[str replace:@"\"" with:@"&quot;"]];
	return [str trimWhiteSpace];
}

@end