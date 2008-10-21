#import <Cocoa/Cocoa.h>
#include "Renderer.h"


@interface GLView : NSOpenGLView
{
	Renderer *renderer;
}

@end
