import GLibObject
import Gtk

public extension Stack {

	public func setVisible(child: Widget, onComplete completionHandler: @escaping () -> Void) {
		setVisible(child: child)
		var signalId: Int?
		signalId = onNotify() { [weak self] (_, parameter) in
			print("Running on notify from onComplete")
			if parameter.name == "transition-running" {
				completionHandler()
				if let signalId = signalId {
					self?.signalHandlerDisconnect(handlerID: signalId)
					print("Disconnected")
				}
			}
		}
	}

}
