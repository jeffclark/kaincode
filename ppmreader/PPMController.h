//
//  PPMController.h
//  PPMReader
//
//  Created by Kevin Wojniak on 8/29/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// http://astronomy.swin.edu.au/~pbourke/dataformats/ppm/
// http://www.csit.fsu.edu/~burkardt/cpp_src/cpp_src.html

#import <Cocoa/Cocoa.h>


@interface PPMController : NSObject
{
	IBOutlet NSImageView *imageView;
	IBOutlet NSTextField *textField;
}

- (IBAction)go:(id)sender;

@end
