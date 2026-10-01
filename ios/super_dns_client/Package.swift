// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "super_dns_client",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "super-dns-client", targets: ["super_dns_client"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "super_dns_client",
            dependencies: [],
            resources: [],
            cSettings: [
                .headerSearchPath("include/super_dns_client")
            ],
            linkerSettings: [
                .linkedLibrary("resolv")
            ]
        )
    ]
)
