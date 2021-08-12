// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GtkKit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GtkKit",
            targets: ["GtkKit"]),
            .executable(name: "TestApp", targets: ["TestApp"])
    ],
    dependencies: [
        .package(name: "gir2swift", url: "https://github.com/rhx/gir2swift.git", .branch("main")),
        .package(name: "Gtk", url: "https://github.com/rhx/SwiftGtk.git", .branch("main")),
        .package(url: "https://github.com/onmyway133/DeepDiff.git", .exact("2.3.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GtkKit",
            dependencies: ["Gtk", "DeepDiff"]),
        .testTarget(
            name: "GtkKitTests",
            dependencies: ["GtkKit"]),
        .target(
        	name: "TestApp",
        	dependencies: ["GtkKit"],
        	resources: [
        		.copy("ui.glade"),
        		.copy("icons")
        	]
        )
    ]
)
