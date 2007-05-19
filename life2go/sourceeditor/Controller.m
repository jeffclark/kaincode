#import "Controller.h"

#define FeedPboardType @"P2GFeedPboardType"

@implementation Controller

- (id)init
{
	sourceNode = [[GroupNode alloc] initWithName:@"root"];
	
	[self import];
	
    return self;
}

- (void)awakeFromNib
{
	//[outlineView setIndentationPerLevel:15.0];
	
	[self updateTotalSources];
	
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:FeedPboardType]];
}

- (void)dealloc
{
	[sourceNode release];
	
	[super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)windowWillClose:(NSNotification *)n
{
	[self export];
}

- (void)importOldSource
{
	NSDictionary *old = [NSDictionary dictionaryWithContentsOfFile:@"/Users/kainjow/Desktop/source.plist"];
	if (!old) return;
	
	NSEnumerator *eKeys = [[old allKeys] objectEnumerator];
	NSString *key;

	while (key = [eKeys nextObject]) {
		NSEnumerator *e = [[(NSDictionary *)[old objectForKey:key] allKeys] objectEnumerator];
		id k;
		
		GroupNode *group = [GroupNode nodeWithName:key];
		while (k = [e nextObject]) {
			NSDictionary *info = [[old objectForKey:key] objectForKey:k];
			NSString *description = [info objectForKey:@"description"];
			NSString *url = [info objectForKey:@"url"];
			NSString *link = [info objectForKey:@"link"];
			FeedNode *feed = [FeedNode nodeWithName:k description:description url:url link:link];
			
			[feed setParent:group];

			[group addChild:feed];
		}
		[sourceNode addChild:group];
	}
	
	[sourceNode sort];
}

- (void)import
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/Users/kainjow/Desktop/source.xml"];
	
	sourceNode = [[self nodeForDict:dict] retain];
}

- (id)nodeForDict:(NSDictionary *)d
{
	if ([d objectForKey:@"Group"]!=nil && [d objectForKey:@"Items"]!=nil) {
		NSEnumerator *e = [[d objectForKey:@"Items"] objectEnumerator];
		id obj;
		GroupNode *node = [GroupNode nodeWithName:[d objectForKey:@"Group"]];
		
		while (obj = [e nextObject]) {
			[node addChild:[self nodeForDict:obj]];
		}
		
		return node;
	} else {
		FeedNode *node = [FeedNode nodeWithName:[d objectForKey:@"name"] description:[d objectForKey:@"description"] url:[d objectForKey:@"url"] link:[d objectForKey:@"link"]];
		return node;
	}
	
	return nil;
}


- (void)export
{
	NSDictionary *dict = [self dictForNode:sourceNode];
	
	[dict writeToFile:@"/Users/kainjow/Desktop/source.xml" atomically:YES];
	
	//[self exportToXML];
}

- (void)exportToXML
{
	NSMutableString *xml = [NSMutableString string];
	
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n"];
	[xml appendString:@"<feeds>\n"];
	[xml appendString:[self xmlForNode:sourceNode]];
	[xml appendString:@"</feeds>\n"];
	
	[xml writeToFile:@"/Users/kainjow/Desktop/feeds.xml" atomically:YES];
}

- (NSString *)xmlForNode:(id)node
{
	NSMutableString *str = [NSMutableString string];
	
	if ([(Node *)node isGroup])
	{
		NSEnumerator *e = [[node children] objectEnumerator];
		id n;
		
		[str appendFormat:@"<category name=\"%@\">\n", [node name]];
		
		while (n = [e nextObject])
			[str appendString:[self xmlForNode:n]];

		[str appendString:@"</category>\n"];
	}
	else
	{
		FeedNode *feedNode = (FeedNode *)node;
		[str appendString:@"<item>\n"];
		[str appendFormat:@"<title>%@</title>\n",
			([feedNode name]		? [[feedNode name] cleanForXML]			: @"")];
		[str appendFormat:@"<description>%@</description>\n", 
			([feedNode description] ? [[feedNode description] cleanForXML]	: @"")];
		[str appendFormat:@"<url>%@</url>\n", 
			([feedNode url]			? [[feedNode url] cleanForXML]		: @"")];
		[str appendFormat:@"<link>%@</link>\n", 
			([feedNode link]		? [[feedNode link] cleanForXML]			: @"")];
		[str appendString:@"</item>\n"];
	}
	
	return str;
}

- (NSDictionary *)dictForNode:(id)node
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if ([(Node *)node isGroup]) {
		NSMutableArray *a = [NSMutableArray array];
		NSEnumerator *e = [[node children] objectEnumerator];
		id n;
		
		while (n = [e nextObject])
			[a addObject:[self dictForNode:n]];
		
		[dict setObject:a forKey:@"Items"];
		[dict setObject:[node name] forKey:@"Group"];
	} else {
		FeedNode *feedNode = (FeedNode *)node;
		[dict setObject:([feedNode name] ? [feedNode name] : @"") forKey:@"name"];
		[dict setObject:([feedNode description] ? [feedNode description] : @"") forKey:@"description"];
		[dict setObject:([feedNode url] ? [feedNode url] : @"") forKey:@"url"];
		[dict setObject:([feedNode link] ? [feedNode link] : @"") forKey:@"link"];
	}
	
	return dict;
}

- (GroupNode *)groupForSelection
{
	GroupNode *node = nil;
	
	if ([outlineView numberOfSelectedRows]==0) {
		node = sourceNode;
	} else {
		id tempNode = [outlineView itemAtRow:[outlineView selectedRow]];
		if ([tempNode isGroup]) {
			node = (GroupNode *)tempNode;
		} else {
			node = (GroupNode *)[(GroupNode *)tempNode parent];
		}
	}
	
	return node;
}

- (GroupNode *)groupForNode:(id)node
{
	if ([node isGroup]) {
		return node;
	} else {
		if ([node parent]!=nil) {
			return (GroupNode *)[node parent];
		} else {
			return sourceNode;
		}
	}
	
	return nil;
}

- (IBAction)save:(id)sender
{
	[self export];
}

- (IBAction)newGroup:(id)sender
{
	GroupNode *node = [self groupForSelection];
	GroupNode *newGroup;
	
	if (node) {
		newGroup = [GroupNode nodeWithName:@"_New Group"];
		[node addChild:newGroup];

		[sourceNode sort];
	
		[outlineView reloadData];
		
		[self outlineViewSelectionDidChange:nil];
	} else {
		NSBeep();
	}
	
	[self updateTotalSources];
}

- (IBAction)remove:(id)sender
{
	NSEnumerator *e = [outlineView selectedRowEnumerator];
	id row;
	
	while (row = [e nextObject]) {
		id node = [outlineView itemAtRow:[row intValue]];
		
		NSLog([[self groupForNode:node] name]);
		[(Node *)[node parent] removeChild:node];
	}
	
	[outlineView deselectAll:nil];
	[outlineView reloadData];
	[self updateTotalSources];
}

- (IBAction)edit:(id)sender
{
    FeedNode *node = [outlineView itemAtRow:[outlineView selectedRow]];
    
	[node setName:[nameField stringValue]];
	[node setDescription:[descriptionField stringValue]];
	[node setURL:[urlField stringValue]];
	[node setLink:[linkField stringValue]];
	
	[sourceNode sort];
	[outlineView reloadData];
}

- (IBAction)add:(id)sender
{
	if (![[nameField stringValue] isEqualToString:@""] && ![[urlField stringValue] isEqualToString:@""]) {
		GroupNode *group = [self groupForSelection];
		FeedNode *node = nil;
		
		node = [FeedNode nodeWithParent:group group:NO];
		[node setName:[nameField stringValue]];
		[node setDescription:[descriptionField stringValue]];
		[node setURL:[urlField stringValue]];
		[node setLink:[linkField stringValue]];
		
		[group addChild:node];
		
		[sourceNode sort];
		[outlineView reloadData];
		
		[nameField setStringValue:@""];
		[descriptionField setStringValue:@""];
		[urlField setStringValue:@""];
		[linkField setStringValue:@""];
	} else {
		NSBeep();
	}
	
	[self updateTotalSources];
}

- (IBAction)addFeeds:(id)sender
{
	NSArray *feeds = [[feedsTextView string] componentsSeparatedByString:@"\n"];
	NSEnumerator *e = [feeds objectEnumerator];
	NSString *feed;
	
	[progressBar setUsesThreadedAnimation:YES];
	[progressBar startAnimation:nil];
	
	while (feed = [e nextObject]) {
		NSURL *url = [NSURL URLWithString:(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)feed, NULL, NULL, kCFStringEncodingUTF8)];
		if (url) {
			RSS *rss;
			NS_DURING
				rss = [[RSS alloc] initWithURL:url normalize:YES];
			NS_HANDLER
				NSLog(@"Error (%@) with %@", [localException reason], url);
				continue;
			NS_ENDHANDLER
			
			if (rss) {
				NSDictionary *headerItems = [rss headerItems];
				GroupNode *group = [self groupForSelection];
				FeedNode *node = nil;
				
				node = [FeedNode nodeWithParent:group group:NO];
				
				[node setName:[headerItems objectForKey:@"title"]];
				[node setLink:[headerItems objectForKey:@"link"]];
				[node setDescription:[headerItems objectForKey:@"description"]];
				[node setURL:[url absoluteString]];
				
				[group addChild:node];
			}
			[rss release];
		}
	}
	
	[progressBar stopAnimation:nil];
	[feedsTextView setString:@""];
	
	[outlineView reloadData];
	[self updateTotalSources];
}

- (void)updateTotalSources
{
    [totalSources setStringValue:[NSString stringWithFormat:@"Total sources: %d", [sourceNode totalNumberOfChildren]]];
}

- (int)outlineView:(NSOutlineView *)outline numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		return [sourceNode numberOfChildren];
	else
		return [(Node *)item numberOfChildren];

	return 0;
    /*if (item == nil) {
        return [source count];
    } else {
        return [[source objectForKey:item] count];
    }*/
}

- (BOOL)outlineView:(NSOutlineView *)outline isItemExpandable:(id)item
{
	return [(Node *)item isGroup];
    //return ([[source objectForKey:item] class] != nil);
}

- (id)outlineView:(NSOutlineView *)outline child:(int)index ofItem:(id)item
{
	if (item == nil)
		return [sourceNode childAtIndex:index];
	else
		return [(Node *)item childAtIndex:index];
	
    /*if (item==nil) {
        NSMutableArray *a = [NSMutableArray array];
        [a setArray:[source allKeys]];
        [a sortUsingSelector:@selector(compare:)];
        return [a objectAtIndex:index];
    } else {
        NSMutableArray *a = [NSMutableArray arrayWithArray:[[source objectForKey:item] allKeys]];
        [a sortUsingSelector:@selector(compare:)];
        return [a objectAtIndex:index];
    }*/
    return nil;
}

- (id)outlineView:(NSOutlineView *)o objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [item name];
}

- (void)outlineView:(NSOutlineView *)o setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if ([(Node *)item isGroup])
		[(GroupNode *)item setName:(NSString *)object];
	else
		[(FeedNode *)item setName:(NSString *)object];
	
	[sourceNode sort];
	[outlineView reloadData];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)n
{
	if ([outlineView numberOfSelectedRows]==1) {
		id tempNode = [outlineView itemAtRow:[outlineView selectedRow]];

		[editButton setEnabled:![tempNode isGroup]];

		if (![tempNode isGroup]) {
			FeedNode *node = (FeedNode *)tempNode;
			
			[nameField setStringValue:[node name]];
			[descriptionField setStringValue:[node description]];
			[urlField setStringValue:[node url]];
			[linkField setStringValue:[node link]];
		} else {
			[nameField setStringValue:@""];
			[descriptionField setStringValue:@""];
			[urlField setStringValue:@""];
			[linkField setStringValue:@""];
		}			
	} else {
		[editButton setEnabled:NO];

		[nameField setStringValue:@""];
		[descriptionField setStringValue:@""];
		[urlField setStringValue:@""];
		[linkField setStringValue:@""];
	}
	
    [removeButton setEnabled:([outlineView numberOfSelectedRows] > 0)];
}

- (BOOL)outlineView:(NSOutlineView *)o shouldSelectItem:(id)item
{
    return YES;//return (![outlineView isExpandable:item]);
}

# pragma mark Dragging

- (BOOL)outlineView:(NSOutlineView *)o writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	draggingInfo = items;
	
	[pboard declareTypes:[NSArray arrayWithObject:FeedPboardType] owner:self];
	[pboard setData:[NSData data] forType:FeedPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)o validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index
{
	//index = NSOutlineViewDropOnItemIndex;
	
	if ([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:FeedPboardType]]!=nil) {
		[outlineView setDropItem:item dropChildIndex:index];
	
		return NSDragOperationGeneric;
	}
	
	return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)o acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
	NSEnumerator *e = [draggingInfo objectEnumerator];
	id eItem;
	NSMutableArray *nodes = [NSMutableArray array];

	while (eItem = [e nextObject]) {
		if ([self groupForNode:item]!=[self groupForNode:eItem] && ![[[self groupForNode:eItem] name] isEqualToString:[[self groupForNode:item] name]]) { // can't insert self into self!
			[[self groupForNode:eItem] removeChild:eItem];							// remove from old group
			[nodes addObject:eItem];
		} else {
			NSLog(@"Can't insert self into descendent (fix!)");
		}
	}

	[[self groupForNode:item] addChildren:nodes];		// no need to use index since it's sorted
	
	[sourceNode sort];
	[outlineView reloadData];
	
	return YES;
}

@end