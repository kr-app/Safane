// SettingsMenu.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsMenu : NSObject <NSMenuDelegate>
{
	NSMenu *_menu;
}

- (NSMenu*)menu;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------