// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "doordash-ios-ble",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "doordash-ios-ble",
            targets: ["doordash-ios-ble"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rhummelmose/BluetoothKit", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "doordash-ios-ble",
            dependencies: ["BluetoothKit"]),
        .testTarget(
            name: "doordash-ios-bleTests",
            dependencies: ["doordash-ios-ble"]),
    ]
)
