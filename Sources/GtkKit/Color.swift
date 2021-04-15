//
//  Color.swift
//  GtkMvc
//
//  Created by Jane Fraser on 23/10/20.
//

import Foundation
import Cairo

public class Color {
	
	public var red: Double;
	
	public var green: Double;
	
	public var blue: Double;
	
	public var alpha: Double
	
	public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
		self.red = red;
		self.green = green;
		self.blue = blue;
		self.alpha = alpha;
	}
	
	public func set(on context: ContextProtocol) {
		context.setSource(red: red, green: green, blue: blue, alpha: alpha);
	}
	
}
