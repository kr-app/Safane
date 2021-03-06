// PreferencesWindowController.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class PreferencesWindowController : NSWindowController,
																NSWindowDelegate,
																THHotKeyFieldViewChangeObserverProtocol {

	@objc static let shared = PreferencesWindowController(windowNibName: "PreferencesWindowController")

	// General
	@IBOutlet var relaunchOnLoginButton: NSButton!
	@IBOutlet var hotKeyButton: NSButton!
	@IBOutlet var hotKeyField: THHotKeyFieldView!

	// Snapshots
	@IBOutlet var refreshIntervalField: NSTextField!
	@IBOutlet var maxCapturesField: NSTextField!

	override func windowDidLoad() {
		super.windowDidLoad()
	
		self.window!.title = THLocalizedString("Safane Preferences")

		let hotKey = THHotKeyRepresentation.init(fromUserDefaultsWithTag: 1)
		hotKeyButton.state = (hotKey != nil && hotKey!.isEnabled == true) ? .on : .off
		hotKeyField.setControlSize(.small)
		hotKeyField.setChangeObserver(self,
																keyCode: hotKey?.keyCode ?? 0,
																modifierFlags: hotKey?.modifierFlags ?? 0,
																isEnabled: hotKey?.isEnabled ?? false)
		
		refreshIntervalField.integerValue = Int(SfUserPref.shared.refreshInterval ?? SfUserPref.defaultRefreshInterval)
		maxCapturesField.integerValue = SfUserPref.shared.maxCaptures ?? SfUserPref.defaultMaxCaptures
	}
	
	// MARK: -

	func windowDidBecomeMain(_ notification: Notification) {
		updateUILoginItem()
	}

	// MARK: -

	private func updateUILoginItem() {
		relaunchOnLoginButton.state = THAppInLoginItem.loginItemStatus()
	}

	// MARK: -
	
	@IBAction func relaunchOnLoginButtonAction(_ sender: NSButton) {
		THAppInLoginItem.setIsLoginItem(sender.state == .on)
		updateUILoginItem()
	}

	@IBAction func hotKeyButtonAction(_ sender: NSButton) {
		self.hotKeyField.setIsEnabled(sender.state == .on)
	}

	// MARK: -

	@objc func hotKeyFieldView(_ sender: THHotKeyFieldView!, didChangeWithKeyCode keyCode: UInt, modifierFlags: UInt, isEnabled: Bool) -> Bool {
		THHotKeyRepresentation(keyCode: keyCode, modifierFlags: modifierFlags, isEnabled: isEnabled).saveToUserDefaults(withTag: 1)
		if isEnabled {
			return THHotKeyCenter.shared().registerHotKey(withKeyCode: keyCode, modifierFlags: modifierFlags, tag: 1)
		}
		return THHotKeyCenter.shared().unregisterHotKey(withTag: 1)
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------
