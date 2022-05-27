// AppDelegate.h

#import <Cocoa/Cocoa.h>
#import "THHotKeyCenter.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@class StMenu;
@class AddRenameWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate,THHotKeyCenterProtocol>
{
	NSStatusItem *_statusItem;
	StMenu *_wsMenu;
	AddRenameWindowController *_renameWindowController;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
