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

/// Dependency lifespan defines whether dependency
/// needs to stay after consumer is deallocated.
public enum Lifespan {
    /// Stays until application is alive.
    case permanent
    /// Deallocated when the last consumer is deallocated.
    case temporary
}

