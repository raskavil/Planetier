// swift-tools-version: 5.9

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Planetier",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Planetier",
            targets: ["AppModule"],
            teamIdentifier: "57C78B97UA",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .rocket),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            appCategory: .productivity
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)