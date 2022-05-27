// AddRenameWindowController.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@class SfWorkspace;

@interface AddRenameWindowController : NSWindowController <NSControlTextEditingDelegate>
{
	NSInteger _mode;
	SfWorkspace *_workspace;
//	BOOL _isSheet;
//	Ws_bkCompletion _endCompletion;
}

@property (nonatomic,strong) IBOutlet NSTextField *nameLabel;
@property (nonatomic,strong) IBOutlet NSTextField *nameField;
@property (nonatomic,strong) IBOutlet NSButton *okButton;
@property (nonatomic,strong) IBOutlet NSProgressIndicator *loadingIndicator;

- (void)presentForMode:(NSInteger)mode workspace:(SfWorkspace*)workspace;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
