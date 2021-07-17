import GLibObject
import Gtk

public class AlertController: PresentationController {

	public var messageDialog: MessageDialog! {
		get {
			return container as! MessageDialog
		}
	}

	public var title: String?

	public var message: String?

	public private(set) var actions: [AlertAction]

	public var preferredAction: AlertAction?

	private var textEntryConfigurators: [((Entry) -> Void)?]

	public private(set) var textEntries: [Entry]

	private var onResponseSignalID: Int?

	public init(title: String?, message: String?) {
		self.title = title
		self.message = message
		actions = []
		preferredAction = nil
		textEntryConfigurators = []
		textEntries = []
	}

	public override func beginPresentation() {
		container = MessageDialog(buttons: .none, text: title ?? "", secondaryText: message)
		messageDialog.setTransientFor(parent: ancestor(ofType: WindowController.self)?.window)
		messageDialog.set(position: .centerOnParent)
		for i in 0..<actions.count {
			let action = actions[i]
			// Respond id is the index of the relevant action
			let button = messageDialog.addButton(buttonText: action.title, responseID: i)
			if action.style == .destructive {
				button?.styleContext.addClass(className: "destructive-action")
			}
			if action.style == .suggested {
				button?.styleContext.addClass(className: "suggested-action")
			}
			action.button = button
		}
		if let preferredIndex = actions.firstIndex(where: { (action) -> Bool in
			return action === preferredAction
		}) {
			messageDialog.setDefaultResponse(responseID: preferredIndex)
		}
		for entryConfigurator in textEntryConfigurators {
			let entry = Entry()
			entryConfigurator?(entry)
			textEntries.append(entry)
			entry.marginStart = 8
			entry.marginEnd = 8
			messageDialog.contentArea.packEnd(child: entry, expand: false, fill: false, padding: 0)
		}
		onResponseSignalID = messageDialog.onResponse() { [weak self] (_, responseID) in
			self?.actions[responseID].activate()
			self?.presentingController?.dismiss()
		}
		messageDialog.showAll()
	}

	public override func endPresentation() {
		if let signalID = onResponseSignalID {
			signalHandlerDisconnect(instance: messageDialog, handlerID: signalID)
		}
		messageDialog?.close()
		container = nil
		for action in actions {
			action.button = nil
		}
	}

	public func addAction(_ action: AlertAction) {
		actions.append(action)
	}

	public func addEntry(configurationHandler handler: ((Entry)-> Void)?) {
		textEntryConfigurators.append(handler)
	}

}

public class AlertAction {

	public enum Style {
		case `default`
		case cancel
		case destructive
		case suggested
	}

	private unowned var controller: AlertController?

	public var title: String?

	public var style: Style

	public var action: ((AlertAction) -> Void)?

	public var isEnabled: Bool = true {
		didSet {
			button?.sensitive = isEnabled
		}
	}

	internal var button: WidgetRef?

	public init(title: String?, style: Style = .default, handler: ((AlertAction) -> Void)? = nil) {
		self.title = title
		self.style = style
		self.action = handler
	}

	internal func activate() {
		action?(self)
	}


}
