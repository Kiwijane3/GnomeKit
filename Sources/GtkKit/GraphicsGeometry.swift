//
//  GraphicsGeometry.swift
//  GtkMvc
//
//  Created by Jane Fraser on 23/10/20.
//

import Foundation

// CGPoint is a lightweight struct for storing a 2D point for graphical operations. Because the name Point might be confusing in code working with multiple coordinate systems, and GPoint was already defined by Gtk's dependencies, this struct is named after the equivalent datatype in UIKit for familiarity.
public struct CGPoint: Equatable {

	static let zero = CGPoint(x: 0, y: 0);
	
	public var x: Double;
	
	public var y: Double;
	
	public init(x: Double, y: Double) {
		self.x = x;
		self.y = y;
	}
	
	public init(x: Int, y: Int) {
		self.x = Double(x);
		self.y = Double(y);
	}
	
	public init() {
		self.x = 0.0;
		self.y = 0.0;
	}
	
	public static func ==(a: CGPoint, b: CGPoint) -> Bool {
		return a.x == b.x && a.y == b.y;
	}
	
}

// CGSize represents the size of a rectangle. It shares a prefix with CGPoint for consistency.
public struct CGSize: Equatable {
	
	
	public static let zero = CGSize(width: 0, height: 0);
	
	public var width: Double;

	public var height: Double;
	
	public init(width: Double, height: Double) {
		self.width = width;
		self.height = height;
	}
	
	public init(width: Int, height: Int) {
		self.width = Double(width);
		self.height = Double(height);
	}
	
	public static func ==(a: CGSize, b: CGSize) -> Bool {
		return a.width == b.width && a.height == b.height;
	}
	
}

// CGRect represents a rectangle, such as a widget's bounds or the bounding box of a path. It shares a prefix with CGPoint for consistency.
public struct CGRect: Equatable {
	
	public var origin: CGPoint;
	
	public var size: CGSize;
	
	public init(origin: CGPoint, size: CGSize) {
		self.origin = origin;
		self.size = size;
	}
	
	public static func ==(a: CGRect, b: CGRect) -> Bool {
		return a.origin == b.origin && a.size == b.size;
	}
	
}
