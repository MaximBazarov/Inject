//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2023 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation

/// Represents an operation source context. Intended to be used in logging.
///
/// *Example:*  `MyClass` reads value in one of its functions,
/// the context for the reading operation would be that function call of the reading function.
///
/// **Parent context**: You can also link the parent context for the operation that require
/// that information.
public final class Context: Sendable {
    public let file: String
    public let fileID: String
    public let line: Int
    public let column: Int
    public let function: String

    public init(file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
    }
}

extension Context: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(file):\(line):\(column)"
    }
}
