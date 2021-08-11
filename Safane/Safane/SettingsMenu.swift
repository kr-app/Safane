// SettingsMenu.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SettingsMenu : NSObject, NSMenuDelegate {
	@objc var menu: NSMenu!

	override init() {
		super.init()
		menu = NSMenu(withTitle: "App-Menu", delegate: self, autoenablesItems: false)
	}

	// MARK: -
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		menu.removeAllItems()

		menu.addItem(THMenuItem(withTitle: THLocalizedString("About Safane…"), block: {() -> Void in
			NSApplication.shared.activate(ignoringOtherApps: true)
			NSApplication.shared.orderFrontStandardAboutPanel(nil)
		}))

		menu.addItem(NSMenuItem.separator())
		menu.addItem(THMenuItem(withTitle: THLocalizedString("Preferences…"), block: {() -> Void in
			NSApplication.shared.activate(ignoringOtherApps: true)
			PreferencesWindowController.shared.showWindow(nil)
		}))

		menu.addItem(NSMenuItem.separator())
		menu.addItem(THMenuItem(withTitle: THLocalizedString("Quit Safane"), block: {() -> Void in
			NSApplication.shared.terminate(nil)
		}))
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
