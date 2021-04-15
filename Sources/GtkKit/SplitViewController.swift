import Foundation
import Gtk

/// The split view controller displays the widgets of up to three children, arranged horizontal. It can display a centered child, whose widget fulls all available space, and widgets on either side of the of the controller. These can be arranged in a variety of ways, according to the layoutStyle variable, and the side widgets can be dismissed.

public enum SplitViewLayoutStyle {
	/// This layout style places the primary controller's view on the leading edge, with the detail in the center.
	case leadingPrimary
	/// This layout places the primary controller's view in the center, with the detail on the trailing edge
	case trailingDetail
	/// This layout places the primary controller's view on the leading edge, the detail's in the center, and the tertiary controller on the trailing edge.
	case tripanel
}

public class SplitWidgetController: WidgetController {


}
