// StMenu.m

#import "StMenu.h"
#import "THFoundation.h"
#import "THLog.h"
#import "THNSMenuExtensions.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation StMenu

- (NSMenu*)menu { return _menu; }

- (id)init
{
	if (self=[super init])
	{
		_menu=[[NSMenu alloc] initWithTitle:@"StatusMenu" delegate:self autoenablesItems:NO];

		_appIcon=[[[NSWorkspace sharedWorkspace] iconForFile:[NSBundle mainBundle].bundlePath] copy];
		_appIcon.size=NSMakeSize(16.0,16.0);

		_mi_menuAttrs=@{ NSFontAttributeName:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]] };
		_mi_boldAttrs=@{ NSFontAttributeName:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]] };
		_mi_nlAttrs=@{ NSFontAttributeName:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]] };
		
		_settingsMenu=[[SettingsMenu alloc] init];
	}
	return self;
}

- (NSMenuItem*)menuItem:(NSString*)title representedObject:(id)representedObject tag:(NSInteger)tag isEnabled:(BOOL)isEnabled
{
	return [NSMenuItem th_menuItemWithTitle:title target:self action:@selector(mi_menu:) representedObject:representedObject tag:tag isEnabled:isEnabled];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
	if (menu==_menu)
	{
		[menu removeAllItems];

		// Safari
		static NSImage *safIcon=nil;
		if (safIcon==nil)
		{
			NSURL *URL=[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.Safari"];
			safIcon=URL==nil?nil:[[[NSWorkspace sharedWorkspace] iconForFile:URL.path] copy];
			safIcon.size=NSMakeSize(16.0,16.0);
		}

		if ([NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"].count>0)
			[menu addItem:[self menuItem:THLocalizedString(@"Bring Safari to Front") representedObject:nil tag:1 isEnabled:YES]];
		else
			[menu addItem:[self menuItem:THLocalizedString(@"Open Safari") representedObject:nil tag:2 isEnabled:YES]];
		menu.th_lastItem.image=safIcon;
//		[menu addItem:[NSMenuItem separatorItem]];

		// Workspaces
		SfWorkspace *selectedWorkspace=[SfWorkspaceManager shared].selectedWorkspace;
		SfWorkspace *defaultWorkspace=[SfWorkspaceManager shared].defaultWorkspace;

		SfWorkspace *currentWs=selectedWorkspace!=nil?selectedWorkspace:defaultWorkspace;
		THException(currentWs==nil,@"currentWs==nil");
		
		if ([[SfWorkspaceManager shared] takeCaptureOfWorkspace:currentWs]==NO)
			THLogError(@"takeCaptureOfWorkspace==NO currentWs:%@",currentWs);

		NSArray *workspaces=[SfWorkspaceManager shared].workspaces;

		for (SfWorkspace *workspace in workspaces)
		{
			[menu addItem:[NSMenuItem separatorItem]];
			
			NSString *title=workspace.name;
			NSMenuItem *menuItem=[self menuItem:title representedObject:workspace tag:3 isEnabled:YES];

			SfWindow *frontWin=workspace.lastCapture.frontWindow;

			NSImage *icon=nil;
			if (frontWin!=nil)
			{
				SfTab *tab=frontWin.visibleTab;
				if (tab!=nil)
					icon=[[THWebIconLoader shared] iconForHost:tab.host startUpdate:YES allowsGeneric:YES];
			}
	
			if (icon==nil)
				icon=[[[THWebIconLoader shared] genericIcon16] th_imageGray];
			menuItem.image=icon;

			menuItem.state=workspace==currentWs?NSControlStateValueOn:NSControlStateValueOff;
			menuItem.attributedTitle=[[NSAttributedString alloc] initWithString:title attributes:workspace==currentWs?_mi_boldAttrs:_mi_nlAttrs];
			menuItem.submenu=[[NSMenu alloc] initWithTitle:@"Workspace-Menu" delegate:self autoenablesItems:NO];
			[menu addItem:menuItem];

			NSArray *windows=workspace.lastCapture.windows;
			if (windows.count==0)
			{
				NSMenuItem *menuItem=[NSMenuItem th_menuItemWithTitle:THLocalizedStringFormat(@"(Empty)") tag:0 isEnabled:NO];
				menuItem.image=[[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
				[menu addItem:menuItem];
			}

			for (SfWindow *window in windows)
			{
				SfTab *tab=window.visibleTab;
				NSString *title=[tab displayTitle:350.0 withAttrs:_mi_menuAttrs];

				NSMenuItem *menuItem=[NSMenuItem th_menuItemWithTitle:title tag:0 isEnabled:NO];
				menuItem.indentationLevel=1;

				NSImage *icon=[[THWebIconLoader shared] iconForHost:tab.host startUpdate:YES allowsGeneric:YES];

//				menuItem.image=[[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
				menuItem.image=[icon th_imageGray];
//				if (window==windows.firstObject)
//					menuItem.attributedTitle=[[NSAttributedString alloc] initWithString:title attributes:_mi_menuAttrs];
		
				menuItem.toolTip=tab.title;
				[menu addItem:menuItem];
			}
		}

		// New Workspace
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[self menuItem:THLocalizedString(@"New Workspace…") representedObject:nil tag:4 isEnabled:YES]];
		menu.th_lastItem.image=[NSImage imageNamed:@"NSAddTemplate"];

		// App Menu
		[menu addItem:[NSMenuItem separatorItem]];
		NSMenuItem *menuItem=[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Safane") tag:0];
		menuItem.image=_appIcon;
		menuItem.submenu=_settingsMenu.menu;
		[menu addItem:menuItem];
	}
	else if ([menu.title isEqualToString:@"Workspace-Menu"]==YES)
	{
		[self loadWorkspaceMenu:menu];
	}
	else if ([menu.title isEqualToString:@"captures-menu"]==YES)
	{
		[menu removeAllItems];
		if (menu.supermenu.highlightedItem==nil)
			return;

		SfWorkspace *workspace=menu.supermenu.highlightedItem.representedObject;
		THException(workspace==nil,@"workspace==nil");

		for (SfCapture *capture in workspace.captures)
		{
			BOOL hasContent=NO;
			for (SfWindow *win in capture.windows)
			{
				for (SfTab *tab in win.tabs)
					if (tab.url!=nil && [tab.url isEqualToString:@"about:blank"]==NO)
					{
						hasContent=YES;
						break;
					}
			}
			
			if (hasContent==NO)
				continue;

			static THTodayDateFormatter *today_df=nil;
			if (today_df==nil)
			{
				NSDateFormatter *df=[[NSDateFormatter alloc] initWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
				today_df=[[THTodayDateFormatter alloc] initWithTodayFormat:@"HMS" otherFormat:nil otherFormatter:df];
			}
			
			NSString *title=[today_df stringFromDate:capture.date];
			NSMenuItem *mi=[self menuItem:title representedObject:@{@"workspace": workspace, @"capture": capture} tag:5 isEnabled:YES];
			if (capture==workspace.lastCapture)
				mi.attributedTitle=[[NSAttributedString alloc] initWithString:title attributes:_mi_boldAttrs];
			mi.submenu=[[NSMenu alloc] initWithTitle:@"capture-menu" delegate:self autoenablesItems:NO];
			[menu addItem:mi];
		}
	}
	else if ([menu.title isEqualToString:@"capture-menu"]==YES)
	{
		[menu removeAllItems];
		if (menu.supermenu.highlightedItem==nil)
			return;

		NSDictionary *ro=menu.supermenu.highlightedItem.representedObject;

		SfWorkspace *workspace=ro[@"workspace"];
		THException(workspace==nil,@"workspace==nil");

		SfCapture *capture=ro[@"capture"];
		THException(capture==nil,@"capture==nil");

		[menu addItem:[self menuItem:THLocalizedString(@"Delete") representedObject:@{@"workspace": workspace, @"capture": capture} tag:6 isEnabled:YES]];
		[menu addItem:[NSMenuItem separatorItem]];

		[self loadCaptureMenu:menu capture:capture workspace:workspace];
	}
	else if ([menu.title isEqualToString:@"App-Menu"]==YES)
	{
		[(id<NSMenuDelegate>)[NSApplication sharedApplication].delegate menuNeedsUpdate:menu];
	}
}

- (void)loadWorkspaceMenu:(NSMenu*)menu
{
	if (menu.supermenu.highlightedItem==nil)
		return;

	SfWorkspace *workspace=menu.supermenu.highlightedItem.representedObject;
	THException(workspace==nil,@"workspace==nil");

	SfWorkspace *selectedWorkspace=[SfWorkspaceManager shared].selectedWorkspace;
	SfWorkspace *defaultWorkspace=[SfWorkspaceManager shared].defaultWorkspace;

//	if (workspace==selectedWorkspace || workspace==defaultWorkspace)
//	{
//		if ([[SfWorkspaceManager shared] takeCaptureOfWorkspace:workspace]==NO)
//			THLogError(@"takeCaptureOfWorkspace==NO workspace:%@",workspace);
//	}

	[menu removeAllItems];

	if (workspace==selectedWorkspace || workspace==defaultWorkspace)
	{
		NSString *title=THLocalizedString(@"Define as Current Workspace");
		[menu addItem:[NSMenuItem th_menuItemWithTitle:title tag:0 isEnabled:NO]];
	}
	else
	{
		NSString *title=THLocalizedString(@"Define as Current Workspace");
		[menu addItem:[self menuItem:title representedObject:workspace tag:11 isEnabled:YES]];
	}

	[menu addItem:[self menuItem:THLocalizedString(@"Rename…") representedObject:workspace tag:12 isEnabled:YES]];
	[menu addItem:[self menuItem:THLocalizedString(@"Delete…") representedObject:workspace tag:13 isEnabled:YES]];
	[menu addItem:[NSMenuItem separatorItem]];

	NSMenuItem *mi=[self menuItem:THLocalizedString(@"Captures") representedObject:workspace tag:0 isEnabled:YES];
	mi.submenu=[[NSMenu alloc] initWithTitle:@"captures-menu" delegate:self autoenablesItems:NO];
	[menu addItem:mi];
	[menu addItem:[NSMenuItem separatorItem]];

	[self loadCaptureMenu:menu capture:workspace.lastCapture workspace:workspace];
}

- (void)loadCaptureMenu:(NSMenu*)menu capture:(SfCapture*)capture workspace:(SfWorkspace*)workspace
{
	NSArray *windows=capture.windows;
	if (windows==0)
		[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"(Empty)") tag:0 isEnabled:NO]];

	for (SfWindow *window in windows)
	{
		if (menu.th_lastItem.isSeparatorItem==NO)
			[menu addItem:[NSMenuItem separatorItem]];

		SfTab *selectedTab=window.visibleTab;

//			NSString *currentTab=[selectedTab displayTitle:60];
//			NSMenuItem *menuItem=[self menuItem:currentTab!=nil?currentTab:@"" representedObject:nil tag:0 isEnabled:NO];
//			menuItem.image=[SfWindow genericIcon16];
//			menuItem.toolTip=window.visibleTab.title;
//			[menu addItem:menuItem];

		for (SfTab *tab in window.tabs)
		{
			NSString *title=[tab displayTitle:350.0 withAttrs:_mi_menuAttrs];

			NSMenuItem *mi=[self menuItem:title representedObject:@{@"workspace":workspace,@"tab":tab} tag:14 isEnabled:YES];
//			mi.attributedTitle=[[NSAttributedString alloc] initWithString:title attributes:tab==selectedTab?_mi_boldAttrs:_mi_nlAttrs];

			mi.state=tab==selectedTab?NSControlStateValueOn:NSControlStateValueOff;
			mi.enabled=tab.url!=nil?YES:NO;
			mi.image=[[THWebIconLoader shared] iconForHost:tab.host startUpdate:YES allowsGeneric:YES];
			mi.toolTip=[NSString stringWithFormat:@"%@\n%@",tab.url,tab.title];

			//menuItem.indentationLevel=1;
			[menu addItem:mi];
		}
	}
}

- (void)mi_menu:(NSMenuItem*)sender
{
	// main menu
	if (sender.tag==1 || sender.tag==2) // open safari
	{
		NSURL *URL=[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.Safari"];
		if (URL==nil || [[NSWorkspace sharedWorkspace] openURL:URL]==NO)
			THLogError(@"openURL==NO URL:%@",URL);
	}
	else if (sender.tag==3) // Switch to Workspace
	{
		SfWorkspace *ws=sender.representedObject;
		THException(ws==nil,@"ws==nil");

		if ([[SfWorkspaceManager shared] switchToWorkspace:ws]==NO)
			THLogError(@"restoreCapture==NO ws:%@",ws);
	}
	else if (sender.tag==4) // New Workspace
	{
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		_renameWindowController=[[AddRenameWindowController alloc] initWithWindowNibName:@"RenameWindowController"];
		[_renameWindowController presentForMode:'n' workspace:sender.representedObject];
	}
	else if (sender.tag==5) // restore capture
	{
		NSDictionary *rep=sender.representedObject;

		SfWorkspace *ws=rep[@"workspace"];
		THException(ws==nil,@"ws==nil");

		SfCapture *capture=rep[@"capture"];
		THException(capture==nil,@"capture==nil");

		if ([[SfWorkspaceManager shared] restoreCapture:capture ofWorkspace:ws]==NO)
			THLogError(@"restoreCapture==NO capture:%@ ws:%@",capture,ws);
	}
	else if (sender.tag==6) // delete capture
	{
		NSDictionary *rep=sender.representedObject;

		SfWorkspace *ws=rep[@"workspace"];
		THException(ws==nil,@"ws==nil");

		SfCapture *capture=rep[@"capture"];
		THException(capture==nil,@"capture==nil");

		if ([[SfWorkspaceManager shared] deleteCapture:capture ofWorkspace:ws]==NO)
			THLogError(@"deleteCapture==NO capture:%@ ws:%@",capture,ws);
	}
	// ws-menu
	if (sender.tag==11) // workspace - define/select
	{
		[[SfWorkspaceManager shared] setCurrentWorkspace:sender.representedObject];
	}
	else if (sender.tag==12) // workspace - rename
	{
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		_renameWindowController=[[AddRenameWindowController alloc] initWithWindowNibName:@"RenameWindowController"];
		[_renameWindowController presentForMode:'r' workspace:sender.representedObject];
	}
	else if (sender.tag==13) // workspace - delete
	{
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
		SfWorkspace *selectedWorkspace=[SfWorkspaceManager shared].selectedWorkspace;

		SfWorkspace *workspace=sender.representedObject;
		THException(workspace==nil,@"workspace==nil");

		NSString *title=THLocalizedStringFormat(@"Are you sure you want to delete workspace \"%@\"?",workspace.name);
		NSString *msg=THLocalizedString(@"This action cannot be canceled.");

		NSMutableArray *buttons=[NSMutableArray arrayWithObjects:THLocalizedString(@"Cancel"),nil];
		[buttons addObject:THLocalizedString(@"Delete")];
		if (workspace==selectedWorkspace)
			[buttons addObject:THLocalizedString(@"Delete And Close Windows")];

		NSModalResponse resp=[[[NSAlert alloc] initWithTitle:title message:msg buttons:buttons] runModal];
		if (resp==NSAlertSecondButtonReturn || resp==NSAlertThirdButtonReturn)
		{
			BOOL closeWins=resp==NSAlertThirdButtonReturn?YES:NO;
			if ([[SfWorkspaceManager shared] closeWorkspace:workspace closeWindows:closeWins]==NO)
				THLogError(@"closeWorkspace==NO workspace:%@",workspace);
		}
	}
	else if (sender.tag==14) // open capture-tab-link
	{
		SfWorkspace *workspace=[(NSDictionary*)sender.representedObject objectForKey:@"workspace"];
		THException(workspace==nil,@"workspace==nil");

		SfWorkspace *selectedWorkspace=[SfWorkspaceManager shared].selectedWorkspace;
		SfWorkspace *defaultWorkspace=[SfWorkspaceManager shared].defaultWorkspace;
	
		if (workspace!=selectedWorkspace && workspace!=defaultWorkspace)
			return;
	
		SfTab *tab=[(NSDictionary*)sender.representedObject objectForKey:@"tab"];
		if (tab.url==nil)
			return;

		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:tab.url]];
	}

}

- (void)menuWillOpen:(NSMenu *)menu
{
	if (menu==_menu)
		[(id<NSMenuDelegate>)[NSApplication sharedApplication].delegate menuWillOpen:menu];
}

- (void)menuDidClose:(NSMenu *)menu
{
	if (menu==_menu)
		[(id<NSMenuDelegate>)[NSApplication sharedApplication].delegate menuDidClose:menu];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
