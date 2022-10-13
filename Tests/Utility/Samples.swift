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

import Inject

protocol NetworkingInterface: AnyObject {}
protocol AuthInterface: AnyObject {}
protocol CrossDependencyAInterface: AnyObject {}
protocol CrossDependencyBInterface: AnyObject {}

final class Network: NetworkingInterface {
    @Injected(\.crossDependencyA,
               lifespan: .temporary,
               scope: .local
    ) var crossReferenceA
    @Injected(\.crossDependencyB,
               lifespan: .permanent,
               scope: .shared
    ) var crossReferenceB
}

actor Auth: AuthInterface {
    @Injected(\.crossDependencyB,
               lifespan: .temporary,
               scope: .local
    ) var crossReferenceB
    @Injected(\.crossDependencyA,
               lifespan: .permanent,
               scope: .shared
    ) var crossReferenceA
}

actor CrossDependencyA: CrossDependencyAInterface {
    @Injected(\.crossDependencyB) var crossReference
}

final class CrossDependencyB: CrossDependencyBInterface {
    @Injected(\.crossDependencyA) var crossReference
}

extension DefaultValues {
    var network: NetworkingInterface { Network() }
    var auth: AuthInterface { Auth() }
    var crossDependencyA: CrossDependencyAInterface { CrossDependencyA() }
    var crossDependencyB: CrossDependencyBInterface { CrossDependencyB() }
}
