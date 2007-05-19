/* $Id: ScanController.mm,v 1.10 2005/04/27 21:05:24 titer Exp $

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.m0k.org/>.
   It may be used under the terms of the GNU General Public License. */

#import "ScanController.h"
#import "DvdDisk.h"

@implementation ScanController

- (id)initWithDelegate:(id)delegate
{
	if (self = [super init])
	{
		_delegate = delegate;
		_dvd = nil;
	}
	
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	[_dvd release];
	
	[super dealloc];
}

- (void)loadDVDs
{
	[self setDVD:nil];
	
	NSArray *dvds = [DvdDisk allDVDs];
	_dvd = ([dvds count] ? [[dvds objectAtIndex:0] retain] : nil);
	
	if (_delegate && [_delegate respondsToSelector:@selector(dvdStartReading:)])
		[_delegate performSelector:@selector(dvdStartReading:) withObject:_dvd];

	if (_dvd == nil)
		return;

    hb_scan(fHandle, [[_dvd bsdPath] UTF8String], 0);
}

- (void)setHandle:(hb_handle_t *)handle
{
    fHandle = handle;
}

- (void)UpdateUI:(hb_state_t *)s
{
    switch (s->state)
    {
#define p s->param.scanning
        case HB_STATE_SCANNING:
		{
            //[fStatusField setStringValue:[NSString stringWithFormat:_( @"Scanning title %d of %d..." ), p.title_cur, p.title_count]];
            //[fIndicator setDoubleValue: 100.0 * (p.title_cur - 1) / p.title_count];
            break;
		}
#undef p

        case HB_STATE_SCANDONE:
		{
			if (_delegate && [_delegate respondsToSelector:@selector(dvdFinishReading:)])
				[_delegate performSelector:@selector(dvdFinishReading:) withObject:_dvd];

            //if (hb_list_count(hb_get_titles(fHandle)))
			break;
		}
    }
}

- (DvdDisk *)dvd
{
	return _dvd;
}

- (void)setDVD:(DvdDisk *)dvd
{
	if (_dvd != dvd)
	{
		[_dvd release];
		_dvd = [dvd retain];
	}
}

@end
