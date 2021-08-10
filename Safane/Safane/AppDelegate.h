// AppDelegate.h

#import <Cocoa/Cocoa.h>
#import "StMenu.h"
#import "THHotKeyCenter.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate,THHotKeyCenterProtocol>
{
	NSStatusItem *_statusItem;
	StMenu *_wsMenu;
	AddRenameWindowController *_renameWindowController;
}

- (IBAction)showPreferences:(NSMenuItem*)sender;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
