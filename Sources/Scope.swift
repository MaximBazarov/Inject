//
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

/// Defines the way an instance is obtained.
public enum Scope {
    /// New instance of a dependency.
    case local
    /// Shared among other consumers, created if needed.
    case shared
}

