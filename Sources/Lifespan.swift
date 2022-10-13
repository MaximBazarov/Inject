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

/// Dependency lifespan defines whether dependency
/// needs to stay after consumer is deallocated.
public enum Lifespan {
    /// Stays until application is alive.
    case permanent
    /// Deallocated when the last consumer is deallocated.
    case temporary
}

