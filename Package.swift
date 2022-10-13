// swift-tools-version:5.7
//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
import PackageDescription

let package = Package(
    name: "Inject",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v4),
        .tvOS(.v11),
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
            name: "Inject-Tests", dependencies: ["Inject"], path: "Tests"
        )
    ]
)
