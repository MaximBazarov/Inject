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

/// Represents the source context for an operation, such as a function call or a value read.
/// The context is primarily used for logging purposes.
///
/// For example, if MyClass reads a value within one of its functions, the context for
/// the reading operation would be the function call of the reading function.
public final class Context: Sendable {
    public let file: String
    public let fileID: String
    public let line: Int
    public let column: Int
    public let function: String

    /// Creates a new context with the provided information.
    ///
    /// - Parameters:
    ///   - file: The source file where the operation takes place. Defaults to the calling function's file.
    ///   - fileID: The unique identifier of the source file. Defaults to the calling function's file ID.
    ///   - line: The line number within the source file where the operation takes place. Defaults to the calling function's line number.
    ///   - column: The column number within the source file where the operation takes place. Defaults to the calling function's column number.
    ///   - function: The name of the function where the operation takes place. Defaults to the calling function's name.

    public init(file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
    }
}

extension Context: CustomDebugStringConvertible {

    /// A textual representation of the context, including the file, line, and column information.
    public var debugDescription: String {
        "\(file):\(line):\(column)"
    }
}
