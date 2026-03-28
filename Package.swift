// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AccessibilityBook",
    defaultLocalization: "ru",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "AccessibilityBook",
            targets: ["AccessibilityBook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.4"),
    ],
    targets: [
        .target(
            name: "AccessibilityBook"),
    ]
)
