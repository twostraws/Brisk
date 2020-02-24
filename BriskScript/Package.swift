// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BriskScript",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "BriskScript", dependencies: [], path: "." )
    ]
)
