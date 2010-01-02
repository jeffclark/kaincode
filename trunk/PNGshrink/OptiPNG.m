//
//  OptiPNG.m
//  PNGshrink
//
//  Created by Kevin Wojniak on 1/2/10.
//  Copyright 2010 Kevin Wojniak. All rights reserved.
//

#import "OptiPNG.h"

/** Application-defined printf callback **/
static void
app_printf(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	NSString *str = [[NSString alloc] initWithUTF8String:fmt];
	NSLogv(str, args);
	[str release];
	va_end(args);
}

/** Application-defined control print callback **/
static void
app_print_cntrl(int cntrl_code)
{
    const char *con_str = NULL;
	
    if (cntrl_code == '\r')
    {
        /* CR: reset line in console, new line in log file. */
        con_str = "\r";
    }
    else if (cntrl_code == '\v')
    {
        /* VT: new line if current line is not empty, nothing otherwise. */
		con_str = "\n";
    }
	
	if (con_str)
		NSLog(@"%s", con_str);
}

/** Application-defined progress update callback **/
static void
app_progress(unsigned long current_step, unsigned long total_steps)
{
	printf("current_step: %d (total_steps: %d)\n", (int)current_step, (int)total_steps);
}

/** Panic handling **/
static void
panic(const char *msg)
{
	/* Print the panic message to stderr and terminate abnormally. */
	NSLog(@"** INTERNAL ERROR: %s", msg);
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[NSApp terminate:nil];
	}];
}


@implementation OptiPNG

- (id)init
{
	if (self = [super init])
	{
		struct opng_ui ui;
	
		// Initialize the optimization engine.
		ui.printf_fn      = app_printf;
		ui.print_cntrl_fn = app_print_cntrl;
		ui.progress_fn    = app_progress;
		ui.panic_fn       = panic;

		if (opng_initialize(&options, &ui) != 0)
		{
			NSLog(@"Can't initialize optimization engine");
			[self release];
			return nil;
		}
		
		queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:1]; // optipng is not thread safe
	}
	
	return self;
}	

- (void)processFiles:(NSArray *)files completionHandler:(void (^)())handler
{
	[queue addOperationWithBlock:^{
		for (NSString *file in files)
			if (opng_optimize([file fileSystemRepresentation]) != 0)
				NSLog(@"Couldn't optimize %@", file);
				
		if (handler)
			if ([queue operationCount] == 1) // will be 1 when this block is the last operation
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					handler();
				}];
	}];
}

@end
