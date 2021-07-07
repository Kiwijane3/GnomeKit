//  ModelPresentation.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk



public class ModalPresentation {

	public enum Style {
		case modal
	}

	public var style: Style = .modal

}

public func createPresentationController(for presentation: ModalPresentation) -> PresentationController {
	switch presentation.style {
		case .modal:
			return ModalWindowController()
	}
}
