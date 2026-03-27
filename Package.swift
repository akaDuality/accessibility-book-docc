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
    targets: [
        .target(
            name: "AccessibilityBook"),
    ]
)
