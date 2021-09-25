import Foundation
import Gdk
import CGtk
import Gtk

// A menu button is a button that displays an action menu when clicked
public class MenuButton: Button {

	public var menu: ActionMenu?

	public var position: GtkPositionType = .bottom

	public init(iconName: String? = nil, size: IconSize = .button, menu: ActionMenu, position: GtkPositionType = .bottom) {
		super.init(iconName: iconName, size: size)
		self.menu = menu
		self.position = position
		configure()
	}

	public init(label: String, menu: ActionMenu, position: GtkPositionType = .bottom) {
		super.init(label: label)
		self.menu = menu
		configure()
	}

	public init(mnemonic: String, menu: ActionMenu, position: GtkPositionType = .bottom) {
		super.init(mnemonic: mnemonic)
		self.menu = menu
		configure()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
		configure()
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
		configure()
	}

	private func configure() {
		onClicked() { [unowned self] (_) in
			menu?.present(from: self)
		}
		becomeSwiftObj()
	}

}
