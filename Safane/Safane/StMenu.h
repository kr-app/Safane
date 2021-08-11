// StMenu.h

#import <Cocoa/Cocoa.h>
#import "AddRenameWindowController.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@class SettingsMenu;

@interface StMenu : NSObject <NSMenuDelegate>
{
	NSMenu *_menu;
	NSImage *_appIcon;
	
	NSDictionary *_mi_menuAttrs;
	NSDictionary *_mi_boldAttrs;
	NSDictionary *_mi_nlAttrs;
	
	SettingsMenu *_settingsMenu;
	AddRenameWindowController *_renameWindowController;
}

- (NSMenu*)menu;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
