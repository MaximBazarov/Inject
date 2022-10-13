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

import XCTest
import Inject

@MainActor
final class Temporary_Local_Tests: XCTestCase {
    
    final class ClassUnderTest: Injectable {
        @Injected(\.network, lifespan: .temporary, scope: .local) var network
        @Injected(\.auth, lifespan: .temporary, scope: .local) var auth
        @Injected(\.crossDependencyA, lifespan: .temporary, scope: .local) var crossDependencyA
        @Injected(\.crossDependencyB, lifespan: .temporary, scope: .local) var crossDependencyB
        
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
        @Injected(\.network, lifespan: .temporary, scope: .local) var network
        @Injected(\.auth, lifespan: .temporary, scope: .local) var auth
        @Injected(\.crossDependencyA, lifespan: .temporary, scope: .local) var crossDependencyA
        @Injected(\.crossDependencyB, lifespan: .temporary, scope: .local) var crossDependencyB
        
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
    
    func test_Class_when_consumerDeallocates_instance_shouldBeDeallocated() {
        var sut: ClassUnderTest? = ClassUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        
        XCTAssertNil(network)
        XCTAssertNil(auth)
        XCTAssertNil(crossDependencyA)
        XCTAssertNil(crossDependencyB)
    }
    
    func test_Class_when_consumerDeallocates_newClass_shouldHaveDifferentInstance() {
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
        
        XCTAssertNotEqual(id(network), id(networkNew))
        XCTAssertNotEqual(id(auth), id(authNew))
        XCTAssertNotEqual(id(crossDependencyA), id(crossDependencyANew))
        XCTAssertNotEqual(id(crossDependencyB), id(crossDependencyBNew))
    }
    
    func test_Class_when_twoConsumers_both_shouldHaveDifferentInstances() {
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
        
        XCTAssertNotEqual(id(network1), id(network2))
        XCTAssertNotEqual(id(auth1), id(auth2))
        XCTAssertNotEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertNotEqual(id(crossDependencyB1), id(crossDependencyB2))
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
    
    func test_Actor_when_consumerDeallocates_instance_shouldBeDeallocated() {
        var sut: ActorUnderTest? = ActorUnderTest()
        
        weak var network = sut?.network.instance
        weak var auth = sut?.auth.instance
        weak var crossDependencyA = sut?.crossDependencyA.instance
        weak var crossDependencyB = sut?.crossDependencyB.instance
        
        sut = nil
        
        XCTAssertNil(network)
        XCTAssertNil(auth)
        XCTAssertNil(crossDependencyA)
        XCTAssertNil(crossDependencyB)
    }
    
    func test_Actor_when_consumerDeallocates_newActor_shouldHaveDifferentInstance() {
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
        
        XCTAssertNotEqual(id(network), id(networkNew))
        XCTAssertNotEqual(id(auth), id(authNew))
        XCTAssertNotEqual(id(crossDependencyA), id(crossDependencyANew))
        XCTAssertNotEqual(id(crossDependencyB), id(crossDependencyBNew))
    }
    
    func test_Actor_when_twoConsumers_both_shouldHaveDifferentInstances() {
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
        
        XCTAssertNotEqual(id(network1), id(network2))
        XCTAssertNotEqual(id(auth1), id(auth2))
        XCTAssertNotEqual(id(crossDependencyA1), id(crossDependencyA2))
        XCTAssertNotEqual(id(crossDependencyB1), id(crossDependencyB2))
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


