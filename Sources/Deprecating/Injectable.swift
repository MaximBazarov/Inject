//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//
import Foundation

@available(*, deprecated, message: "This api isn't available, please refer to Readme.")
public protocol Injectable {}

@available(*, deprecated, message: "This api isn't available, please refer to Readme.")
public extension Injectable {
    @available(*, deprecated, message: "This api isn't available, please refer to Readme.")
    @MainActor func injecting<Value>(
        _ newValue: Value,
        for keyPath: KeyPath<Self, Dependency<Value>>
    ) -> Self {
        let dependency = self[keyPath: keyPath]
        dependency.override(with: newValue)
        return self
    }
}

