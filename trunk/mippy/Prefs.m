#import "Prefs.h"


@implementation Prefs

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    return self;
}

- (void)dealloc
{
    [super release];
}

- (void)awakeFromNib
{
    [[matrix cellAtRow:0 column:0] setState:[[[NSUserDefaults standardUserDefaults] objectForKey:@"dock"] boolValue]];
    [[matrix cellAtRow:1 column:0] setState:[[[NSUserDefaults standardUserDefaults] objectForKey:@"menu"] boolValue]];
}

- (IBAction)save:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[matrix cellAtRow:0 column:0] state]] forKey:@"dock"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[matrix cellAtRow:1 column:0] state]] forKey:@"menu"];
}

@end
