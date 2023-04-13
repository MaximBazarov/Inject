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

/// Defines the way an instance is obtained.
public enum Scope {
    /// New instance of a dependency.
    case local
    /// Shared among other consumers, created if needed.
    case shared
}

