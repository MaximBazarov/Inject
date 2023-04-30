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

extension InstanceProviders {
    var depOnConsumerWhenLastLeave: Injection<ReportingObject> { .init(
        create: .onConsumer,
        deallocate: .whenLastConsumerLeave,
        instance: ReportingObject()
    )}

    var depOnConsumerNeverDeallocated: Injection<ReportingObject> { .init(
        create: .onConsumer,
        deallocate: .neverDeallocated,
        instance: ReportingObject()
    )}

    var depSharedWhenLastConsumerLeave: Injection<ReportingObject> { .init(
        create: .shared,
        deallocate: .whenLastConsumerLeave,
        instance: ReportingObject()
    )}

    var depSharedNeverDeallocated: Injection<ReportingObject> { .init(
        create: .shared,
        deallocate: .neverDeallocated,
        instance: ReportingObject()
    )}
}

class Consumer_OnConsumerNeverDeallocated {
    @Instance(\.depOnConsumerNeverDeallocated) var dependencyA
}
class Consumer_OnConsumerWhenLastLeave {
    @Instance(\.depOnConsumerWhenLastLeave) var dependencyA
}

class Consumer_SharedNeverDeallocated {
    @Instance(\.depSharedNeverDeallocated) var dependencyA
}
class Consumer_SharedWhenLastConsumerLeave {
    @Instance(\.depSharedWhenLastConsumerLeave) var dependencyA
}

final class Integration_Tests: XCTestCase {

    @MainActor func test_OnConsumer_NeverDeallocates() throws {
        var sut = Optional(Consumer_OnConsumerNeverDeallocated())
        var sut1 = Optional(Consumer_OnConsumerNeverDeallocated())
        var wasDestroyed = false
        var wasDestroyed1 = false

        XCTAssertNotEqual(
            ObjectIdentifier(sut!.dependencyA),
            ObjectIdentifier(sut1!.dependencyA)
        )

        sut!.dependencyA.onDestroy = { wasDestroyed = true }
        sut1!.dependencyA.onDestroy = { wasDestroyed1 = true }

        sut = nil
        XCTAssertTrue(wasDestroyed)

        sut1 = nil
        XCTAssertTrue(wasDestroyed1)
    }

    @MainActor func test_OnConsumer_WhenLastConsumerLeaves() throws {
        var sut = Optional(Consumer_OnConsumerWhenLastLeave())
        var sut1 = Optional(Consumer_OnConsumerWhenLastLeave())
        var wasDestroyed = false
        var wasDestroyed1 = false

        XCTAssertNotEqual(
            ObjectIdentifier(sut!.dependencyA),
            ObjectIdentifier(sut1!.dependencyA)
        )

        sut!.dependencyA.onDestroy = { wasDestroyed = true }
        sut1!.dependencyA.onDestroy = { wasDestroyed1 = true }

        sut = nil
        XCTAssertTrue(wasDestroyed)

        sut1 = nil
        XCTAssertTrue(wasDestroyed1)
    }

    @MainActor func test_Shared_NeverDeallocated() throws {
        var sut = Optional(Consumer_SharedNeverDeallocated())
        var sut1 = Optional(Consumer_SharedNeverDeallocated())
        var wasDestroyed = false

        XCTAssertEqual(
            ObjectIdentifier(sut!.dependencyA),
            ObjectIdentifier(sut1!.dependencyA)
        )

        sut!.dependencyA.onDestroy = { wasDestroyed = true }

        sut = nil
        XCTAssertFalse(wasDestroyed)

        sut1 = nil
        XCTAssertFalse(wasDestroyed)
    }

    @MainActor func test_Shared_WhenLastConsumerLeave() throws {
        var sut = Optional(Consumer_SharedWhenLastConsumerLeave())
        var sut1 = Optional(Consumer_SharedWhenLastConsumerLeave())
        var wasDestroyed = false

        XCTAssertEqual(
            ObjectIdentifier(sut!.dependencyA),
            ObjectIdentifier(sut1!.dependencyA)
        )

        sut!.dependencyA.onDestroy = { wasDestroyed = true }

        sut = nil
        XCTAssertFalse(wasDestroyed)

        sut1 = nil
        XCTAssertTrue(wasDestroyed)
    }

}

class ReportingObject {
    var onDestroy: () -> Void = {}

    deinit {
        onDestroy()
    }
}
