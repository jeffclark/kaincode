/* $Id: ScanController.h,v 1.4 2005/03/21 12:37:32 titer Exp $

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.m0k.org/>.
   It may be used under the terms of the GNU General Public License. */

#import <Cocoa/Cocoa.h>
#import "hb.h"

@class DvdDisk;

@interface ScanController : NSObject
{
    hb_handle_t *fHandle;
	id _delegate;
	DvdDisk *_dvd;
}

- (id)initWithDelegate:(id)delegate;

- (void)setHandle:(hb_handle_t *)handle;
- (void)UpdateUI:(hb_state_t *)state;

- (void)loadDVDs;

- (DvdDisk *)dvd;
- (void)setDVD:(DvdDisk *)dvd;

@end
