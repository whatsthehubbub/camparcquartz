//
//  AppController.h
//  video
//
//  Created by Matthew Donoughe on 2011-02-12.
//  Copyright __MyCompanyName__ 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#include <vlc/vlc.h>
libvlc_instance_t * vlcInstance = nil;

@interface AppController : NSObject 
{
    IBOutlet QCView* qcView;
	IBOutlet NSWindow* window;
	IBOutlet NSTextField* inputField0;
	IBOutlet NSTextField* inputField1;
	IBOutlet NSTextField* inputField2;
}

- (QCView*)qcView;
- (IBAction)toggleFullscreen:(id)sender;
- (IBAction)playFile:(id)sender;

@end
