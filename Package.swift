// swift-tools-version:5.7

//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15),
    ],
    products: [
        .library(name: "Inject", targets: ["Inject"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Inject", dependencies: [], path: "Sources"
        ),
        .testTarget(
            name: "Unit-Tests", dependencies: ["Inject"], path: "Tests/Unit"
        ),
        .testTarget(
            name: "Integration-Tests", dependencies: ["Inject"], path: "Tests/Integration"
        ),
        .testTarget(
            name: "Overrides-Tests", dependencies: ["Inject"], path: "Tests/Overrides"
        )
    ]
)
