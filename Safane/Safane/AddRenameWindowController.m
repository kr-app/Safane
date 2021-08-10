// AddRenameWindowController.m

#import "AddRenameWindowController.h"
#import "THFoundation.h"
#import "THLog.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation AddRenameWindowController

- (void)presentForMode:(NSInteger)mode workspace:(SfWorkspace*)workspace
{
	_mode=mode;
	_workspace=workspace;
	//_isSheet=sheetParent!=nil?YES:NO;
	//_endCompletion=endCompletion;

	NSString *name=nil;
	if (mode=='n')
	{
		NSString *baseName=THLocalizedString(@"Workspace");
		for (NSInteger i=0;i<100;i++)
		{
			name=i==0?baseName:[baseName stringByAppendingFormat:@" %ld",i];
			if ([[SfWorkspaceManager shared] workspaceNamed:name]==nil)
				break;
		}
	}
	else if (mode=='r')
	{
		name=workspace.name;
	}

	self.window.title=mode=='n'?THLocalizedString(@"New Workspace"):THLocalizedString(@"Rename Workspace");
	self.nameField.objectValue=name;
	[self.okButton setEnabled:self.nameField.stringValue.length>0?YES:NO];
	[self.loadingIndicator stopAnimation:nil];

//	if (_isSheet==YES)
//		[[NSApplication sharedApplication] beginSheet:self.window modalForWindow:sheetParent modalDelegate:nil didEndSelector:nil contextInfo:NULL];
//	else	
		[self.window makeKeyAndOrderFront:nil];
}

- (void)controlTextDidChange:(NSNotification*)notification
{
	if (notification.object==self.nameField)
	{
		NSString *name=self.nameField.stringValue;
		name=[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[self.okButton setEnabled:name.length>0?YES:NO];
	}
}

- (IBAction)changeAction:(NSButton*)sender
{
	if (sender==self.okButton)
		if ([self validateAction]==NO)
			return;
	[self.window orderOut:nil];
}

- (IBAction)nameFieldAction:(NSTextField*)sender
{
	if ([self validateAction]==YES)
		[self.window orderOut:nil];
}

- (BOOL)validateAction
{
	NSString *name=self.nameField.stringValue;
	name=[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (name.length>0)
	{
		[self.loadingIndicator startAnimation:nil];
		
		if (_mode=='n')
		{
			if ([[SfWorkspaceManager shared] addWorkspaceWithName:self.nameField.stringValue]==NO)
				THLogError(@"addWorkspaceWithName==NO");
		}
		else if (_mode=='r')
		{
			if ([[SfWorkspaceManager shared] renameWorkspace:_workspace withName:self.nameField.stringValue]==NO)
				THLogError(@"renameWorkspace==NO");
		}

		[self.loadingIndicator stopAnimation:nil];

		return YES;
	}

	return NO;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
