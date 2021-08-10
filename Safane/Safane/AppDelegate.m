// AppDelegate.m

#import "AppDelegate.h"
#import "THFoundation.h"
#import "THLog.h"
#import "THNSMenuExtensions.h"
#import "THStatusIconAlfredFirst.h"
#import "SfScript.h"
#import "StatusIcon.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	THLogInfo(@"config:%@",[THRunningApp config]);
	
#ifdef DEBUG
	[THRunningApp killOtherApps:nil];
	[SfScript autoEnlaceScripts];
//	[StatusIcon generateAppIcon];
#endif

	[[SfWorkspaceManager shared] startAndCaptureNow:YES];
	
	_wsMenu=[[StMenu alloc] init];

	_statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	_statusItem.button.image=[StatusIcon statusItemImage:NO];
	_statusItem.button.alternateImage=[StatusIcon statusItemImage:YES];
	_statusItem.menu=_wsMenu.menu;

	THHotKeyRepresentation *hotKey=[THHotKeyRepresentation hotKeyRepresentationFromUserDefaults];
	[[THHotKeyCenter shared] tryToRegisterHotKeyRepresentation:hotKey withTag:1];

	if ([THStatusIconAlfredFirst needsDisplayAlfredFirst]==YES)
		[self performSelector:@selector(showAlfredFirstDelayed) withObject:nil afterDelay:0.5];
}

- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{
}

- (void)applicationWillResignActive:(NSNotification*)aNotification
{
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
//	[[THCrashReporter sharedInstance] applicationTerminated];
}

#pragma mark -

- (void)showAlfredFirstDelayed
{
	[THStatusIconAlfredFirst setNeedsDisplayAlfredFirst:NO];
	
	NSWindow *siWindow=_statusItem.button.window;
	if (siWindow==nil)
		return;

	NSRect winRect=siWindow.frame;
	[THStatusIconAlfredFirst showAtPosition:CGFloatFloor(winRect.origin.x+(winRect.size.width/2.0)) onScreen:siWindow.screen];
}

#pragma mark -

- (void)hotKeyCenter:(THHotKeyCenter*)sender pressedHotKey:(NSDictionary*)tag
{
	[_statusItem.button performClick:nil];
}

#pragma mark -

- (void)menuWillOpen:(NSMenu *)menu
{
	[[SfWorkspaceManager shared] stop];
}

- (void)menuDidClose:(NSMenu *)menu
{
	[[SfWorkspaceManager shared] startAndCaptureNow:NO];
}

#pragma mark -

- (IBAction)showPreferences:(NSMenuItem*)sender
{
	[[PreferencesWindowController shared] showWindow:nil];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
