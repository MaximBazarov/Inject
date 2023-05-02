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
// MARK: - Description
//
// Testing that Strategy definition is guaranteed.
//===----------------------------------------------------------------------===//

@MainActor final class Strategy_Tests: XCTestCase {

    func test_OnDemand() throws {
        var sut = Optional(Consumer_OnDemand())
        var sut1 = Optional(Consumer_OnDemand())
        weak var instance = sut?.service
        weak var instance1 = sut1?.service

        XCTAssertNotEqual(
            ObjectIdentifier(instance as AnyObject),
            ObjectIdentifier(instance1 as AnyObject)
        )

        sut = nil
        XCTAssertNil(instance)

        sut1 = nil
        XCTAssertNil(instance1)
    }

    func test_Singleton() throws {
        var sut = Optional(Consumer_Singleton())
        var sut1 = Optional(Consumer_Singleton())
        weak var instance = sut?.service

        XCTAssertEqual(
            ObjectIdentifier(instance as AnyObject),
            ObjectIdentifier(sut1!.service)
        )

        sut = nil
        XCTAssertNotNil(instance)

        sut1 = nil
        XCTAssertNotNil(instance)
    }

    func test_Shared() throws {
        var sut = Optional(Consumer_Shared())
        var sut1 = Optional(Consumer_Shared())
        weak var instance = sut?.service

        XCTAssertEqual(
            ObjectIdentifier(instance as AnyObject),
            ObjectIdentifier(sut1!.service)
        )

        sut = nil
        XCTAssertNotNil(instance)

        sut1 = nil
        XCTAssertNil(instance)
    }

}

//===----------------------------------------------------------------------===//
// MARK: - Utility
//===----------------------------------------------------------------------===//


protocol Service: AnyObject {
    func doWork()
}

@MainActor let shared = Injection<Service>(strategy: .shared, instance: TestService())
@MainActor let singleton = Injection<Service>(strategy: .singleton, instance: TestService())
@MainActor let onDemand = Injection<Service>(strategy: .onDemand, instance: TestService())

class TestService: Service {
    func doWork() {}
}

class Consumer_Shared {
    @Instance(shared) var service
}

class Consumer_Singleton {
    @Instance(singleton) var service
}

class Consumer_OnDemand {
    @Instance(onDemand) var service
}
