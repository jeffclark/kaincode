#import "GLView.h"


@implementation GLView

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attr[] = 
	{
        NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute) 32,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) 23,
		(NSOpenGLPixelFormatAttribute) 0
	};
	NSOpenGLPixelFormat *nsglFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attr] autorelease];
	
    if (self = [super initWithFrame:frameRect pixelFormat:nsglFormat])
		renderer = new Renderer();
	return self;
}

- (void)prepareOpenGL
{
	renderer->InitGL();
}

- (void)drawRect:(NSRect)rect
{
	renderer->DrawGL();
}

@end
