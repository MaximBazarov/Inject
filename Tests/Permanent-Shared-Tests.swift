//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Inject package
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

@MainActor
final class Permanent_Shared_Tests: XCTestCase {
    
    final class ClassUnderTest: Injectable {
        @Injected(\.network, lifespan: .permanent, scope: .shared) var network
        @Injected(\.auth, lifespan: .permanent, scope: .shared) var auth
        @Injected(\.crossDependencyA, lifespan: .permanent, scope: .shared) var crossDependencyA
        @Injected(\.crossDependencyB, lifespan: .permanent, scope: .shared) var crossDependencyB
        
        func testIntegrity() -> Bool {
            let network = id(network)
            let auth = id(auth)
            let crossDependencyA = id(crossDependencyA)
            let crossDependencyB = id(crossDependencyB)
            
            return network != auth
            && auth != crossDependencyA
            && crossDependencyA != crossDependencyB
            && crossDependencyB != auth
        }
    }
    
    actor ActorUnderTest: Injectable {
        @Injected(\.network, lifespan: .permanent, scope: .shared) var network
        @Injected(\.auth, lifespan: .permanent, scope: .shared) var auth
        @Injected(\.crossDependencyA, lifespan: .permanent, scope: .shared) var crossDependencyA
        @Injected(\.crossDependencyB, lifespan: .permanent, scope: .shared) var crossDependencyB
        
        func testIntegrity() async -> Bool{
            let network = id(await network)
            let auth = id(await auth)
            let crossDependencyA = id(await crossDependencyA)
            let crossDependencyB = id(await crossDependencyB)
            
            return network != auth
            && auth != crossDependencyA
            && crossDependencyA != crossDependencyB
            && crossDependencyB != auth
        }
    }
    
    // MARK: - Class
    func test_Class_DependenciesIntegrity() {
        let sut = ClassUnderTest()
        XCTAssertTrue(sut.testIntegrity())
    }
    
    func test_Class_when_consumerDeallocates_it_shouldPersistTheInstance() {
        var sut: ClassUnderTest? = ClassUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        
        XCTAssertNotNil(network)
        XCTAssertNotNil(auth)
        XCTAssertNotNil(crossDependencyA)
        XCTAssertNotNil(crossDependencyB)
    }
    
    func test_Class_when_consumerDeallocates_newClass_shouldHaveTheSameInstance() {
        var sut: ClassUnderTest? = ClassUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        sut = ClassUnderTest()
        
        weak var networkNew = sut?.network.instance
        weak var authNew = sut?.auth.instance
        weak var crossDependencyANew = sut?.crossDependencyA.instance
        weak var crossDependencyBNew = sut?.crossDependencyB.instance
        
        XCTAssertEqual(id(network), id(networkNew))
        XCTAssertEqual(id(auth), id(authNew))
        XCTAssertEqual(id(crossDependencyA), id(crossDependencyANew))
        XCTAssertEqual(id(crossDependencyB), id(crossDependencyBNew))
    }
    
    func test_Class_when_twoConsumers_both_shouldHaveSameInstances() {
        let sut1 = ClassUnderTest()
        
        let network1 = sut1.network.instance
        let auth1 = sut1.auth.instance
        let crossDependencyA1 = sut1.crossDependencyA.instance
        let crossDependencyB1 = sut1.crossDependencyB.instance
        
        let sut2 = ClassUnderTest()
        
        let network2 = sut2.network.instance
        let auth2 = sut2.auth.instance
        let crossDependencyA2 = sut2.crossDependencyA.instance
        let crossDependencyB2 = sut2.crossDependencyB.instance
        
        XCTAssertEqual(id(network1), id(network2))
        XCTAssertEqual(id(auth1), id(auth2))
        XCTAssertEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertEqual(id(crossDependencyB1), id(crossDependencyB2))
    }
    
    // MARK: Injecting
    func test_Class_when_Injecting_instance_returnsInjectedInstance() {
        let sut1 = ClassUnderTest()
        
        let network1 = sut1.network.instance
        let auth1 = sut1.auth.instance
        let crossDependencyA1 = sut1.crossDependencyA.instance
        let crossDependencyB1 = sut1.crossDependencyB.instance
        
        let network = Network()
        let auth = Auth()
        let crossDependencyA = CrossDependencyA()
        let crossDependencyB = CrossDependencyB()
        
        let sut2 = sut1
            .injecting(network, for: \.network)
            .injecting(auth, for: \.auth)
            .injecting(crossDependencyA, for: \.crossDependencyA)
            .injecting(crossDependencyB, for: \.crossDependencyB)
        
        
        let network2 = sut2.network.instance
        let auth2 = sut2.auth.instance
        let crossDependencyA2 = sut2.crossDependencyA.instance
        let crossDependencyB2 = sut2.crossDependencyB.instance
        
        XCTAssertEqual(id(network), id(network2))
        XCTAssertEqual(id(auth), id(auth2))
        XCTAssertEqual(id(crossDependencyA), id(crossDependencyA2))
        XCTAssertEqual(id(crossDependencyB), id(crossDependencyB2))
        
        XCTAssertNotEqual(id(network1), id(network2))
        XCTAssertNotEqual(id(auth1), id(auth2))
        XCTAssertNotEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertNotEqual(id(crossDependencyB1), id(crossDependencyB2))
    }
    
    // MARK: - Actor
    func test_Actor_DependenciesIntegrity() async {
        let sut = ActorUnderTest()
        let integrity = await sut.testIntegrity()
        XCTAssertTrue(integrity)
    }
    
    func test_Actor_when_consumerDeallocates_it_shouldPersistTheInstance() {
        var sut: ActorUnderTest? = ActorUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        
        XCTAssertNotNil(network)
        XCTAssertNotNil(auth)
        XCTAssertNotNil(crossDependencyA)
        XCTAssertNotNil(crossDependencyB)
    }
    
    func test_Actor_when_consumerDeallocates_newActor_shouldHaveTheSameInstance() {
        var sut: ActorUnderTest? = ActorUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        sut = ActorUnderTest()
        
        weak var networkNew = sut?.network.instance
        weak var authNew = sut?.auth.instance
        weak var crossDependencyANew = sut?.crossDependencyA.instance
        weak var crossDependencyBNew = sut?.crossDependencyB.instance
        
        XCTAssertEqual(id(network), id(networkNew))
        XCTAssertEqual(id(auth), id(authNew))
        XCTAssertEqual(id(crossDependencyA), id(crossDependencyANew))
        XCTAssertEqual(id(crossDependencyB), id(crossDependencyBNew))
    }
    
    func test_Actor_when_twoConsumers_both_shouldHaveSameInstances() {
        let sut1 = ActorUnderTest()
        
        let network1 = sut1.network.instance
        let auth1 = sut1.auth.instance
        let crossDependencyA1 = sut1.crossDependencyA.instance
        let crossDependencyB1 = sut1.crossDependencyB.instance
        
        let sut2 = ActorUnderTest()
        
        let network2 = sut2.network.instance
        let auth2 = sut2.auth.instance
        let crossDependencyA2 = sut2.crossDependencyA.instance
        let crossDependencyB2 = sut2.crossDependencyB.instance
        
        XCTAssertEqual(id(network1), id(network2))
        XCTAssertEqual(id(auth1), id(auth2))
        XCTAssertEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertEqual(id(crossDependencyB1), id(crossDependencyB2))
    }
    
    // MARK: Injecting
    func test_Actor_when_Injecting_instance_returnsInjectedInstance() {
        let sut1 = ActorUnderTest()
        
        let network1 = sut1.network.instance
        let auth1 = sut1.auth.instance
        let crossDependencyA1 = sut1.crossDependencyA.instance
        let crossDependencyB1 = sut1.crossDependencyB.instance
        
        let network = Network()
        let auth = Auth()
        let crossDependencyA = CrossDependencyA()
        let crossDependencyB = CrossDependencyB()
        
        let sut2 = sut1
            .injecting(network, for: \.network)
            .injecting(auth, for: \.auth)
            .injecting(crossDependencyA, for: \.crossDependencyA)
            .injecting(crossDependencyB, for: \.crossDependencyB)
        
        
        let network2 = sut2.network.instance
        let auth2 = sut2.auth.instance
        let crossDependencyA2 = sut2.crossDependencyA.instance
        let crossDependencyB2 = sut2.crossDependencyB.instance
        
        XCTAssertEqual(id(network), id(network2))
        XCTAssertEqual(id(auth), id(auth2))
        XCTAssertEqual(id(crossDependencyA), id(crossDependencyA2))
        XCTAssertEqual(id(crossDependencyB), id(crossDependencyB2))
        
        XCTAssertNotEqual(id(network1), id(network2))
        XCTAssertNotEqual(id(auth1), id(auth2))
        XCTAssertNotEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertNotEqual(id(crossDependencyB1), id(crossDependencyB2))
    }
}

