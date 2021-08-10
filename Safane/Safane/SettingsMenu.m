// SettingsMenu.m

#import "SettingsMenu.h"
#import "THFoundation.h"
#import "THLog.h"
#import "THNSMenuExtensions.h"
#import "TH_APP-Swift.h"

@implementation SettingsMenu

- (NSMenu*)menu { return _menu; }

- (id)init
{
	if (self=[super init])
	{
		_menu=[[NSMenu alloc] initWithTitle:@"App-Menu" delegate:self autoenablesItems:NO];;
	}
	return self;
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
	if ([menu.title isEqualToString:@"App-Menu"]==YES)
	{
		[menu removeAllItems];
		[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"About Safane…") target:self action:@selector(mi_about:) tag:0]];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Preferences…") target:self action:@selector(mi_preferences:) tag:0]];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Quit Safane") target:self action:@selector(mi_quit:) tag:0]];
	}
}

- (void)mi_about:(NSMenuItem*)sender
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (void)mi_preferences:(NSMenuItem*)sender
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[PreferencesWindowController shared] showWindow:nil];
}

- (void)mi_quit:(NSMenuItem*)sender
{
	[[NSApplication sharedApplication] terminate:nil];
}

@end
