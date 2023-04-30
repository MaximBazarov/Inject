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

import XCTest
@testable import Inject

protocol Auth: AnyObject {
    var credentials: String { get }
}

final class AuthDefaultImplementation: Auth {
    var credentials: String { "production-creds" }
}

@MainActor extension Auth {
    var `default`: Injection<Auth> { .init(
        create: .shared,
        deallocate: .whenLastConsumerLeave,
        instance: AuthDefaultImplementation()
    )}
}

extension InstanceProviders {
    var auth: Injection<Auth> { .init(
        create: .shared,
        deallocate: .whenLastConsumerLeave,
        instance: AuthDefaultImplementation()
    )}
}

extension Injection {
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
@MainActor final class Storage_Tests: XCTestCase {

    func test_AccessByKeyPath_RefersToSameInstance() throws {
        let keyPath = \InstanceProviders.auth
        XCTAssertEqual(
            InstanceProviders[keyPath].id,
            InstanceProviders[keyPath].id
        )
    }

    func test_Override_readsOverriddenConfiguration() {
        let keyPath = \InstanceProviders.auth
        @Instance(keyPath) var sut

        InstanceProviders.override(keyPath, create: .onConsumer, instance: { _ in AuthDefaultImplementation() })
        XCTAssertNotNil(InstanceProviders[keyPath].overridden)
    }

}
