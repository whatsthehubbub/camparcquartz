//
//  AppController.m
//  video
//
//  Created by Matthew Donoughe on 2011-02-12.
//  Copyright __MyCompanyName__ 2011 . All rights reserved.
//

#import "AppController.h"

#define IMAGEWIDTH 960
#define IMAGEHEIGHT 960

static unsigned char *pixels[3] = {nil, nil, nil};
static NSImage *lastImage[3] = {nil, nil, nil};
static NSAutoreleasePool *pool[3] = {nil, nil, nil};

static libvlc_media_player_t *player[3] = {nil, nil, nil};

//static QCView *qcView;

@implementation AppController

- (QCView*)qcView
{
	return qcView;
}

- (void) awakeFromNib
{
    //NSView *superview = [window contentView];
    //NSRect frame = NSMakeRect(10, 10, 400, 400);
    //qcView = [[QCView alloc] initWithFrame:frame];
    //[superview addSubview:qcView];
    [qcView unloadComposition];
    
    /* Setup QC composition */
	if(![qcView loadCompositionFromFile:[[NSBundle mainBundle] pathForResource:@"composition" ofType:@"qtz"]]) {
		NSLog(@"Could not load composition");
	}
    [qcView setEventForwardingMask :NSAnyEventMask];
    [qcView setMaxRenderingFrameRate: 30.0];
    [qcView startRendering];
    
    /* Load the VLC engine */
	vlcInstance = libvlc_new (0, NULL);
}

- (void)windowWillClose:(NSNotification *)notification 
{
    [qcView unloadComposition];
    [qcView dealloc];
    
	[NSApp terminate:self];
}

- (IBAction)toggleFullscreen:(id)sender {
    if(![qcView isInFullScreenMode]) {
        NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], NSFullScreenModeAllScreens, NULL, NSFullScreenModeApplicationPresentationOptions, nil];
        [qcView enterFullScreenMode:[NSScreen mainScreen] withOptions:opts];
        
        [window makeKeyWindow];
        
    } else {
        [qcView exitFullScreenModeWithOptions:nil];
    }
}

- (IBAction)playFile:(id)sender
{
    int index;
    if(sender == inputField0)
        index = 0;
    else if(sender == inputField1)
        index = 1;
    else if(sender == inputField2)
        index = 2;
    
    /* If the player is already active, stop it first */
    if(player[index]) {
        libvlc_media_player_release(player[index]);
    }

	lastImage[index] = nil;
    pixels[index] = nil;
    pool[index] = nil;
    
    pixels[index] = malloc(IMAGEWIDTH * IMAGEHEIGHT * 4);
	libvlc_media_t *media;

	/* Create a new item */
    NSString *inputString = [sender stringValue];
    if([inputString rangeOfString:@"://"].location == NSNotFound) {
        media = libvlc_media_new_path (vlcInstance, [inputString UTF8String]);
    } else {
        media = libvlc_media_new_location(vlcInstance, [inputString UTF8String]);
    }
	   
	/* Create a media player playing environement */
	player[index] = libvlc_media_player_new_from_media (media);
	libvlc_media_release(media);
	   
    switch(index) {
        case 0:
            libvlc_video_set_callbacks(player[index], lock0, unlock0, display, self);
            break;
        case 1:
            libvlc_video_set_callbacks(player[index], lock1, unlock1, display, self);
            break;
        case 2:
            libvlc_video_set_callbacks(player[index], lock2, unlock2, display, self);
            break;
    }
	libvlc_video_set_format(player[index], "RGBA", IMAGEWIDTH, IMAGEHEIGHT, IMAGEWIDTH * 4);
	libvlc_media_player_play(player[index]);
    
    /* Send path to QC */
    [[self qcView] setValue:inputString forInputKey:[NSString stringWithFormat:@"Path_%d", index]];

}

// libvlc callback stubs
static void *lock0(void *data, void **p_pixels)
{
    return lock(0, data, p_pixels);
}

static void unlock0(void *data, void *id, void * const *p_pixels)
{
    return unlock(0, data, id, p_pixels);
}

static void *lock1(void *data, void **p_pixels)
{
    return lock(1, data, p_pixels);
}

static void unlock1(void *data, void *id, void * const *p_pixels)
{
    return unlock(1, data, id, p_pixels);
}

static void *lock2(void *data, void **p_pixels)
{
    return lock(2, data, p_pixels);
}

static void unlock2(void *data, void *id, void * const *p_pixels)
{
    return unlock(2, data, id, p_pixels);
}


// indexed libvlc callbacks
static void *lock(int index, void *data, void **p_pixels)
{
	*p_pixels = pixels[index];
	return NULL;
}

static void unlock(int index, void *data, void *id, void * const *p_pixels)
{
    if (pool[index] == nil)
		pool[index] = [[NSAutoreleasePool alloc] init];
	
    if (lastImage[index] != nil)
		[lastImage[index] release];
    
	AppController *self = (AppController *)data;
	
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(IMAGEWIDTH, IMAGEHEIGHT)];
    
	NSImageRep *irep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels[index]
                                                               pixelsWide:IMAGEWIDTH
                                                               pixelsHigh:IMAGEHEIGHT
                                                            bitsPerSample:8
                                                          samplesPerPixel:4
                                                                 hasAlpha:YES
                                                                 isPlanar:NO
                                                           colorSpaceName:NSDeviceRGBColorSpace
                                                              bytesPerRow:IMAGEWIDTH * 4
                                                             bitsPerPixel:32];
	[image addRepresentation:irep];
	[irep release];
	
    if([[self qcView] loadedComposition]) {
        [[self qcView] setValue:image forInputKey:[NSString stringWithFormat:@"Image_%d", index]];
    }
    
    lastImage[index] = image;
}

static void display(void *data, void *id)
{
}

@end
