/* Controller */

#import <Cocoa/Cocoa.h>
#import "RSS.h"

#import "Node.h"
#import "FeedNode.h"
#import "GroupNode.h"

@interface Controller : NSObject
{
    IBOutlet NSOutlineView *outlineView;
    IBOutlet NSTextField *totalSources;
    IBOutlet NSButton *editButton;
	IBOutlet NSButton *removeButton;
	IBOutlet NSTextField *nameField, *descriptionField, *urlField, *linkField;
	IBOutlet NSTextView *feedsTextView;
	IBOutlet NSProgressIndicator *progressBar;
    
	GroupNode *sourceNode;
	NSArray *draggingInfo;
}

- (void)importOldSource;
- (void)import;
- (id)nodeForDict:(NSDictionary *)d;
- (void)export;
- (void)exportToXML;
- (NSString *)xmlForNode:(id)node;
- (NSDictionary *)dictForNode:(id)node;

- (GroupNode *)groupForSelection;
- (GroupNode *)groupForNode:(id)node;

- (IBAction)save:(id)sender;

- (IBAction)newGroup:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)edit:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)addFeeds:(id)sender;

- (void)updateTotalSources;

@end
