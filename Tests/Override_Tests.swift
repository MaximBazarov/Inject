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

enum PackageA {
    class Service {
        var result: String = ""
    }

    @MainActor static let sharedService = Injection<Service>(strategy: .shared, instance: Service())
}

@MainActor final class Override_Tests: XCTestCase {

    final class Consumer {
        @Instance(PackageA.sharedService) var service

        func perform() -> String {
            service.result
        }
    }

    let testInjection: PackageA.Service = {
        let injection = PackageA.Service()
        injection.result = "test"
        return injection
    }()

    func test_Override_Local() {
        let sut = Consumer()

        // Not Injected, default result
        XCTAssertEqual(sut.perform(), "")

        sut.service = testInjection

        XCTAssertEqual(sut.perform(), "test")
    }

    func test_Override_Global() {
        let sut = Consumer()

        PackageA.sharedService.override(with: { _ in self.testInjection })

        XCTAssertEqual(sut.perform(), "test")
        PackageA.sharedService.rollbackOverride()
    }


    func test_Override_WithInstance_Rollback_Global() {
        var sut = Consumer()
        PackageA.sharedService.override(with: { _ in self.testInjection })

        XCTAssertEqual(sut.perform(), "test")

        XCTAssertEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))

        PackageA.sharedService.rollbackOverride()
        sut = Consumer()
        XCTAssertNotEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))
    }

    func test_Override_WithInjection_Rollback_Global() {
        var sut = Consumer()
        let override = Injection<PackageA.Service>(strategy: .shared, instance: self.testInjection)
        PackageA.sharedService.override(with: override)

        XCTAssertEqual(sut.perform(), "test")

        XCTAssertEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))

        PackageA.sharedService.rollbackOverride()
        sut = Consumer()
        XCTAssertNotEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))
    }
}
