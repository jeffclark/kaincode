/*

BSD License

Copyright (c) 2002, Brent Simmons
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

*	Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
*	Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
*	Neither the name of ranchero.com or Brent Simmons nor the names of its
	contributors may be used to endorse or promote products derived
	from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


*/

/*
	RSS.m
	A class for reading RSS feeds.

	Created by Brent Simmons on Wed Apr 17 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/


#import "RSS.h"

@implementation RSS


#define titleKey @"title"
#define linkKey @"link"
#define descriptionKey @"description"


/*Public interface*/


- (RSS *) initWithTitle: (NSString *) title andDescription: (NSString *) description {
	
	/*
	Create an empty feed. Useful for synthetic feeds.
	*/
	
	NSMutableDictionary *header;

	flRdf = NO;
	atom = NO;
	
	header = [NSMutableDictionary dictionaryWithCapacity: 2];
	
	[header setObject: title forKey: titleKey];
	
	[header setObject: description forKey: descriptionKey];
	
	headerItems = (NSDictionary *) [header copy];
	
	newsItems = [[NSMutableArray alloc] initWithCapacity: 0];
	
	version = [[NSString alloc] initWithString: @"synthetic"];
	
	return (self);
	} /*initWithTitle*/
	
	
- (RSS *) initWithData: (NSData *) rssData normalize: (BOOL) fl {
	
	CFXMLTreeRef tree;
	
	flRdf = NO;
	atom = NO;
	
	normalize = fl;
	
	NS_DURING
	
		tree = CFXMLTreeCreateFromData (kCFAllocatorDefault, (CFDataRef) rssData,
			NULL,  kCFXMLParserAllOptions/*kCFXMLParserSkipWhitespace*/, kCFXMLNodeCurrentVersion);
	
	NS_HANDLER
		
		NSLog(@"CFXMLTreeCreateFromData threw an exception.");
		
		tree = nil;
	
	NS_ENDHANDLER
	
	if (tree == nil) {
		//NSLog(@"CFXMLTreeCreateFromData returned nil (data length: %d)", [rssData length]);
		
		/*If there was a problem parsing the RSS file,
		raise an exception.*/
	
		NSException *exception = [NSException exceptionWithName: @"RSSParseFailed"
			reason: @"The XML parser could not parse the data." userInfo: nil];
		
		[exception raise];
		} /*if*/
	
	[self createheaderdictionary: tree];
	[self createitemsarray: tree];
	[self setversionstring: tree];

	CFRelease (tree);
	
	return (self);
	} /*initWithData*/


- (RSS *) initWithURL: (NSURL *) url normalize: (BOOL) fl {
	
	NSURLHandle *urlHandle;
	NSData *rssData;
	
	urlHandle = [url URLHandleUsingCache: NO];

	rssData = [urlHandle resourceData];
	
	if ([urlHandle status] == NSURLHandleLoadFailed) {
		
		/*If there was a problem reading the RSS file,
		raise an exception.*/
		
		NSException *exception = [NSException exceptionWithName: @"RSSDownloadFailed"
			reason: [urlHandle failureReason] userInfo: nil];

		[exception raise];
		} /*if*/
	
	if (rssData == nil) {
		
		/*Another possible error.*/
		
		NSException *exception = [NSException exceptionWithName: @"RSSNoData"
			reason: @"Unknown error." userInfo: nil];

		[exception raise];
		} /*if*/
	
	return [self initWithData: rssData normalize: fl];	
	} /*initWithUrl*/


- (NSDictionary *) headerItems {
	return (headerItems);
	} /*headerItems*/


- (NSMutableArray *) newsItems {
	
	return (newsItems);
	} /*newsItems*/


- (NSString *) version {
	
	return (version);
	} /*version*/


- (void) dealloc {
		
	[headerItems release];

	[newsItems release];
	
	[version release];
	} /*dealloc*/



/*Private methods. Don't call these: they may change.*/


- (void) createheaderdictionary: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef channelTree, childTree;
	CFXMLNodeRef childNode;
	int childCount, i;
	NSString *childName;
	NSMutableDictionary *headerItemsMutable;
	
	channelTree = [self getchanneltree: tree];
	
	if (channelTree == nil) {
		
		NSException *exception = [NSException exceptionWithName: @"RSSCreateHeaderDictionaryFailed"
			reason: @"Couldn’t find the channel tree." userInfo: nil];

		[exception raise];
		} /*if*/

	childCount = CFTreeGetChildCount (channelTree);
	
	headerItemsMutable = [NSMutableDictionary dictionaryWithCapacity: childCount];
		
	for (i = 0; i < childCount; i++) {
		
		childTree = CFTreeGetChildAtIndex (channelTree, i);
		
		childNode = CFXMLTreeGetNode (childTree);
		
		childName = (NSString *) CFXMLNodeGetString (childNode);
		
		if ([childName hasPrefix: @"rss:"])
			childName = [childName substringFromIndex: 4];
		
		if ([childName isEqualToString: @"item"])
			break;
		
		if (atom)
			if ([childName isEqualToString:@"entry"]) // Atom
				break;
		
		if ([childName isEqualTo: @"image"])
			[self flattenimagechildren: childTree into: headerItemsMutable];

		[headerItemsMutable setObject: [self getelementvalue: childTree] forKey: childName];
		} /*for*/
	
	headerItems = [headerItemsMutable copy];
	} /*initheaderdictionary*/


- (void) createitemsarray: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef channelTree, childTree, itemTree;
	CFXMLNodeRef childNode, itemNode;
	NSString *childName;
	NSString *itemName;
	id itemValue = nil;
	int childCount, itemChildCount, i, j;
	NSMutableDictionary *itemDictionaryMutable;
	NSMutableArray *itemsArrayMutable;
	
	if (flRdf)
		channelTree = [self getnamedtree: tree name: @"rdf:RDF"];
	else if (atom)
		channelTree = [self getnamedtree: tree name: @"feed"];
	else
		channelTree = [self getchanneltree: tree];
	
	if (channelTree == nil) {
		
		NSException *exception = [NSException exceptionWithName: @"RSSCreateItemsArrayFailed"
			reason: @"Couldn’t find the news items." userInfo: nil];

		[exception raise];
		} /*if*/
	
	childCount = CFTreeGetChildCount (channelTree);
	
	itemsArrayMutable = [NSMutableArray arrayWithCapacity: childCount];

	for (i = 0; i < childCount; i++) {
		
		childTree = CFTreeGetChildAtIndex (channelTree, i);
		
		childNode = CFXMLTreeGetNode (childTree);
		
		childName = (NSString *) CFXMLNodeGetString (childNode);
		
		
		if (atom) { // Atom
			if (![childName isEqualToString: @"entry"])
				continue;
		} else { // RSS
			if ([childName hasPrefix: @"rss:"])
				childName = [childName substringFromIndex: 4];

			if (![childName isEqualToString: @"item"])
				continue;
		}
		
		itemChildCount = CFTreeGetChildCount (childTree);
		
		itemDictionaryMutable = [NSMutableDictionary dictionaryWithCapacity: itemChildCount];

		for (j = 0; j < itemChildCount; j++) {
			
			itemTree = CFTreeGetChildAtIndex (childTree, j);
			
			itemNode = CFXMLTreeGetNode (itemTree);
			
			itemName = (NSString *) CFXMLNodeGetString (itemNode);
			
			if ([itemName hasPrefix: @"rss:"])
				itemName = [itemName substringFromIndex: 4];
			
			if ([self isAtomFeed] && [itemName isEqualTo:@"content"]) {
				// init with XMLTree, get full XML source for this tree (content), remove HTML (xml)
				/*XMLTree *xmlTree = [[XMLTree alloc] initWithCFXMLTreeRef:itemTree];
				itemValue = [[[xmlTree xml] removeCdataStuff] stripHTML];
				[xmlTree release];*/
			} else {
				itemValue = [self getelementvalue: itemTree];
			}
			
			if ([itemName isEqualTo: @"source"])
				[self flattensourceattributes: itemNode into: itemDictionaryMutable];
			
			if (!itemValue) itemValue = @"";

			/* added by me!!!!! */
			if ([itemName isEqualToString:@"enclosure"])
			{
				const CFXMLElementInfo *elementInfo = CFXMLNodeGetInfoPtr(itemNode);
				NSDictionary *a = (NSDictionary *)(* elementInfo).attributes;
				itemValue = a;
			}

			[itemDictionaryMutable setObject: itemValue forKey: itemName];
		}

		//if (normalize) [self normalizeRSSItem: itemDictionaryMutable];
		// add title, description, link if non-existent
		if ([itemDictionaryMutable objectForKey:descriptionKey]==nil)
			[itemDictionaryMutable setObject:@"" forKey:descriptionKey];
		if ([itemDictionaryMutable objectForKey:linkKey]==nil)
			[itemDictionaryMutable setObject:@"" forKey:linkKey];
		
		[itemsArrayMutable addObject: itemDictionaryMutable];
	} /*for*/
	
	newsItems = [itemsArrayMutable copy];
} /*createitemsarray*/


- (void) setversionstring: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef rssTree;
	const CFXMLElementInfo *elementInfo;
	CFXMLNodeRef node;
	NSDictionary *attributes;
	
	if (flRdf) {
		version = [[NSString alloc] initWithString: @"rdf"];
		
		return;
	} /*if*/

	if (atom) {
		rssTree = [self getnamedtree: tree name: @"feed"]; // Atom
	} else {
		rssTree = [self getnamedtree: tree name: @"rss"]; // RSS
	}	
	node = CFXMLTreeGetNode (rssTree);

	elementInfo = CFXMLNodeGetInfoPtr (node);

	attributes = (NSDictionary *)(*elementInfo).attributes;

	if (attributes!=nil) {
		//version = [[NSString alloc] initWithString: [(NSDictionary *) (*elementInfo).attributes objectForKey: @"version"]];	
		if ([attributes objectForKey: @"version"]!=nil)
			version = [[NSString alloc] initWithString:[attributes objectForKey: @"version"]];	
	}
} /*setversionstring*/
	

- (void) flattenimagechildren: (CFXMLTreeRef) tree into: (NSMutableDictionary *) dictionary {
	
	int childCount = CFTreeGetChildCount (tree);
	int i = 0;
	CFXMLTreeRef childTree;
	CFXMLNodeRef childNode;
	NSString *childName, *childValue, *keyName;
	
	if (childCount < 1)
		return;
		
	for (i = 0; i < childCount; i++) {
		
		childTree = CFTreeGetChildAtIndex (tree, i);
		
		childNode = CFXMLTreeGetNode (childTree);
		
		childName = (NSString *) CFXMLNodeGetString (childNode);
		
		if ([childName hasPrefix: @"rss:"])
			childName = [childName substringFromIndex: 4];
		
		childValue = [self getelementvalue: childTree];
		
		keyName = [NSString stringWithFormat: @"image%@", childName];
		
		if (!childValue) childValue = @"";
		[dictionary setObject: childValue forKey: keyName];
		} /*for*/
	} /*flattenimagechildren*/


- (void) flattensourceattributes: (CFXMLNodeRef) node into: (NSMutableDictionary *) dictionary {
	
	const CFXMLElementInfo *elementInfo;
	NSString *sourceHomeUrl, *sourceRssUrl;

	elementInfo = CFXMLNodeGetInfoPtr (node);
	
	sourceHomeUrl = [(NSDictionary *) (*elementInfo).attributes objectForKey: @"homeUrl"];
	
	sourceRssUrl = [(NSDictionary *) (*elementInfo).attributes objectForKey: @"url"];
	
	if (sourceHomeUrl != nil)
		[dictionary setObject: sourceHomeUrl forKey: @"sourceHomeUrl"];
	
	if (sourceRssUrl != nil)
		[dictionary setObject: sourceRssUrl forKey: @"sourceRssUrl"];
	} /*flattensourceattributes*/
	
	
- (CFXMLTreeRef) getchanneltree: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef rssTree, channelTree;
	
	rssTree = [self getnamedtree: tree name: @"rss"];
	
	if (rssTree == nil) { /*It might be "rdf:RDF" instead, a 1.0 or greater feed.*/
	
		rssTree = [self getnamedtree: tree name: @"rdf:RDF"];
		
		if (rssTree != nil) {
			flRdf = YES; /*This info will be needed later when creating the items array.*/
		} else {
			
			// Atom
			rssTree = [self getnamedtree:tree name:@"feed"];
			if (rssTree!=nil) atom=YES;
		}
	}
	
	if (rssTree == nil)
		return (nil);
	
	if (atom) {
		channelTree = rssTree; // there is no channel in Atom - just all in main feed
	} else {
		// normal rss/rdf
		channelTree = [self getnamedtree: rssTree name: @"channel"];
		
		if (channelTree == nil)
			channelTree = [self getnamedtree: rssTree name: @"rss:channel"];
	}
	
	return (channelTree);
	} /*getchanneltree*/


- (CFXMLTreeRef) getnamedtree: (CFXMLTreeRef) currentTree name: (NSString *) name {
	
	int childCount, index;
	CFXMLNodeRef xmlNode;
	CFXMLTreeRef xmlTreeNode;
	NSString *itemName;
	
	childCount = CFTreeGetChildCount (currentTree);
	
	for (index = childCount - 1; index >= 0; index--) {
		
		xmlTreeNode = CFTreeGetChildAtIndex (currentTree, index);
		
		xmlNode = CFXMLTreeGetNode (xmlTreeNode);
		
		itemName = (NSString *) CFXMLNodeGetString (xmlNode);
		
		if ([itemName isEqualToString: name])
			return (xmlTreeNode);
		} /*for*/
	
	return (nil);
	} /*getnamedtree*/


- (void) normalizeRSSItem: (NSMutableDictionary *) rssItem {
	
	/*
	Make sure item, link, and description are present and have
	reasonable values. Description and link may be "".
	Also trim white space, remove HTML when appropriate.
	*/
	
	NSString *description, *link, *title;
	BOOL nilDescription = NO;
	
	/*Description*/
	
	description = [rssItem objectForKey: descriptionKey];
	
	if (description == nil) {
		
		description = @"";
		
		nilDescription = YES;
		} /*if*/
	
	description = [description trimWhiteSpace];
	
	if ([description isEqualTo: @""])
		nilDescription = YES;
	
	[rssItem setObject: description forKey: descriptionKey];

	/*Link*/
	
	link = [rssItem objectForKey: linkKey];
	
	if ([NSString stringIsEmpty: link]) {
		
		/*Try to get a URL from the description.*/
		
		if (!nilDescription) {
					
			NSArray *stringComponents = [description componentsSeparatedByString: @"href=\""];
			
			if ([stringComponents count] > 1) {
							
				link = [stringComponents objectAtIndex: 1];
			
				stringComponents = [link componentsSeparatedByString: @"\""];

				link = [stringComponents objectAtIndex: 0];			
				} /*if*/				
			} /*if*/
		} /*if*/
	
	if (link == nil)
		link = @"";
	
	link = [link trimWhiteSpace];
	
	[rssItem setObject: link forKey: linkKey];
	
	/*Title*/
	
	title = [rssItem objectForKey: titleKey];
		
	if (title != nil) {
	
		title = [title stripHTML];
		
		title = [title trimWhiteSpace];
		} /*if*/
	
	if ([NSString stringIsEmpty: title]) {
		
		/*Grab a title from the description.*/
		
		if (!nilDescription) {

			NSArray *stringComponents = [description componentsSeparatedByString: @">"];
			
			if ([stringComponents count] > 1) {
			
				title = [stringComponents objectAtIndex: 1];
				
				stringComponents = [title componentsSeparatedByString: @"<"];
	
				title = [stringComponents objectAtIndex: 0];
				
				title = [title stripHTML];
				
				title = [title trimWhiteSpace];
				} /*if*/
			
			if ([NSString stringIsEmpty: title]) { /*use first part of description*/
				
				NSString *shortTitle = [[[description stripHTML] trimWhiteSpace] ellipsizeAfterNWords: 5];

				shortTitle = [shortTitle trimWhiteSpace];
				
				title = [NSString stringWithFormat: @"%@...", shortTitle];				
				} /*else*/				
			} /*if*/
		
		// added by kainjow
		if (title==nil) title = @"";
			
		title = [title stripHTML];
	
		title = [title trimWhiteSpace];
	
		if ([NSString stringIsEmpty: title])
			title = @"Untitled";	
		} /*if*/
		
	[rssItem setObject: title forKey: titleKey];
	
	/*dangerousmeta case: super-long title with no description*/
	
	if ((nilDescription) && ([title length] > 50)) {
						
		NSString *shortTitle = [[[title stripHTML] trimWhiteSpace] ellipsizeAfterNWords: 7]; // [title stripHTML]
				
		description = [[title copy] autorelease];
		
		[rssItem setObject: description forKey: descriptionKey];
		
		title = [NSString stringWithFormat: @"%@...", shortTitle];				
		
		[rssItem setObject: title forKey: titleKey];
		} /*if*/

	{ /*deal with entities*/
		
		const char *tempcstring;
		NSAttributedString *s = nil;
		NSString *convertedTitle = nil;
		NSArray *stringComponents;
		
		stringComponents = [title componentsSeparatedByString: @"&"];
		
		if ([stringComponents count] > 1) {
			
			stringComponents = [title componentsSeparatedByString: @";"];
			
			if ([stringComponents count] > 1) {
			
				int len;
				
				tempcstring = [title UTF8String];
				
				len = strlen (tempcstring);
				
				if (len > 0) {
				
					s = [[NSAttributedString alloc]
						initWithHTML: [NSData dataWithBytes: tempcstring length: strlen (tempcstring)]
						documentAttributes: (NSDictionary **) NULL];
		
					convertedTitle = [s string];
				
					[s autorelease];
									
					convertedTitle = [convertedTitle stripHTML];
				
					convertedTitle = [convertedTitle trimWhiteSpace];				
					} /*if*/
				
				if ([NSString stringIsEmpty: convertedTitle])
					convertedTitle = @"Untitled";
				
				[rssItem setObject: convertedTitle forKey: @"convertedTitle"];
				} /*if*/
			} /*if*/
		} /*deal with entities*/
	} /*normalizeRSSItem*/


- (NSString *) getelementvalue: (CFXMLTreeRef) tree {
	
	CFXMLNodeRef node;
	CFXMLTreeRef itemTree;
	int childCount, ix;
	NSMutableString *valueMutable;
	NSString *value;
	NSString *name;
	
	childCount = CFTreeGetChildCount (tree);
	
	valueMutable = [[NSMutableString alloc] init];
	
	for (ix = 0; ix < childCount; ix++) {
		
		itemTree = CFTreeGetChildAtIndex (tree, ix);
		
		node = CFXMLTreeGetNode (itemTree);
		
		name = (NSString *) CFXMLNodeGetString (node);
		
		if ([self isAtomFeed]) {
			if ([name isEqualTo:@"div"]) {
				[self getelementvalue:itemTree];
			}
		}		

		if (name != nil) {
		
			if (CFXMLNodeGetTypeCode (node) == kCFXMLNodeTypeEntityReference) {
				
				if ([name isEqualTo: @"lt"])
					name = @"<";

				else if ([name isEqualTo: @"gt"])
					name = @">";
				
				else if ([name isEqualTo: @"quot"])
					name = @"\"";
				
				else if ([name isEqualTo: @"amp"])
					name = @"&";
				
				else if ([name isEqualTo: @"rsquo"])
					name = @"’";
				
				else if ([name isEqualTo: @"lsquo"])
					name = @"‘";
				
				else if ([name isEqualTo: @"apos"])
					name = @"'";				
				else
					name = [NSString stringWithFormat: @"&%@;", name];
				} /*if*/
						
			[valueMutable appendString: name];
			} /*if*/
		} /*for*/
	
	value = [valueMutable copy];
	
	[valueMutable autorelease];

	return ([value autorelease]);
	} /*getelementvalue*/


- (BOOL)isAtomFeed
{
	return atom;
}

@end
