//
//  Controller.m
//  PieChart
//
//  Created by Kevin Wojniak on Tue Jun 08 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"


@implementation Controller

- (void)awakeFromNib
{
	// use volume info from hard drive
	NSString *volume = @"/";
	float totalSpace = [self totalSpace:volume];
	float freeSpace = [self freeSpace:volume];
	[dataField setStringValue:[NSString stringWithFormat:@"%.1f, %.1f", totalSpace-freeSpace, freeSpace]];
	[self setData:dataField];
}

- (IBAction)setData:(id)sender
{
	
	[pieChart setData:[sender stringValue]];
}

- (IBAction)setRotation:(id)sender
{
	[pieChart setRotation:[sender intValue]];
}

/* See http://www.cocoadev.com/index.pl?DiskSpace   */

- (float)totalSpace:(NSString*)path
{
    unsigned long long sizeValue;
    NSString *fullPath = [path stringByStandardizingPath];
    if (fullPath)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (fileManager)
        {
            NSDictionary *fileSystemAttributes = [fileManager fileSystemAttributesAtPath:fullPath];
            if (fileSystemAttributes && [fileSystemAttributes count])
            {
                NSNumber *keyValue = [fileSystemAttributes objectForKey:NSFileSystemSize];
                if (keyValue)
                {
                    sizeValue = [keyValue unsignedLongLongValue];
					return sizeValue/1048576;
                    //NSLog(@"The total volume size containing the path \"%@\" is %qu", fullPath, sizeValue);
                }
            }
        }
    }
	return 0;
}

- (float)freeSpace:(NSString*)path
{
    unsigned long long sizeValue;
    NSString *fullPath = [path stringByStandardizingPath];
    if (fullPath)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (fileManager)
        {
            NSDictionary *fileSystemAttributes = [fileManager fileSystemAttributesAtPath:fullPath];
            if (fileSystemAttributes && [fileSystemAttributes count])
            {
                NSNumber *keyValue = [fileSystemAttributes objectForKey:NSFileSystemFreeSize];
                if (keyValue)
                {
                    sizeValue = [keyValue unsignedLongLongValue];
                    return sizeValue/1048576;
					//NSLog(@"The current free space on the volume containing \"%@\" is %qu", fullPath, sizeValue);
                }
            }
        }
    }
	return 0;
}

@end
