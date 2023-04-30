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
import Inject

//===----------------------------------------------------------------------===//
// MARK: - Networking Package
//===----------------------------------------------------------------------===//

protocol Networking: AnyObject {
    func perform(_ credentials: String)
}

final class NetworkingDefaultImplementation: Networking {
    func perform(_ credentials: String) {}
}

@MainActor struct NetworkingNameSpace {
    var `default` = Injection<Networking>(
        create: .onConsumer,
        deallocate: .whenLastConsumerLeave,
        instance: NetworkingDefaultImplementation()
    )
}
extension InstanceProviders {
    var networkingNameSpace: NetworkingNameSpace { .init() }
}

//===----------------------------------------------------------------------===//
// MARK: - Auth Package
//===----------------------------------------------------------------------===//

protocol Auth: AnyObject {
    var credentials: String { get }
}

final class AuthDefaultImplementation: Auth {
    var credentials: String { "production-creds" }
}

@MainActor struct AuthNameSpace {
    var `default`: Injection<Auth> { .init(
        create: .onConsumer,
        deallocate: .whenLastConsumerLeave,
        instance: AuthDefaultImplementation()
    )}
}
extension InstanceProviders {
    var authNameSpace: AuthNameSpace { .init() }
}

//===----------------------------------------------------------------------===//
// MARK: - Multi-package Simulation
//===----------------------------------------------------------------------===//



@MainActor final class Overrides_MultiPackageSimulation_Tests: XCTestCase {

    final class ConsumerA: OverridableInjections {
        @Instance(\.authNameSpace.default) var auth
        @Instance(\.networkingNameSpace.default) var networking

        func work() {
            networking.perform(auth.credentials)
        }
    }

    class NetworkingMock: Networking {
        var callback: (String) -> Void

        init(callback: @escaping (String) -> Void) {
            self.callback = callback
        }

        func perform(_ credentials: String) {
            callback(credentials)
        }
    }

    class AuthMock: Auth {
        var credentials: String = "test-overridden"
    }

    func test_Override_LocalInstance_shouldOverride() async {
        let sut = ConsumerA()
        var result: String = ""

        InstanceProviders.override(\.networkingNameSpace.default, create: .shared) { new in
            return NetworkingMock{ result = $0 }
        }

        InstanceProviders.override(\.authNameSpace.default, create: .shared) { new in
            AuthMock()
        }


        sut.work()

        XCTAssertEqual(result, "test-overridden")
    }

}
