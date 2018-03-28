//
//  Loadable.swift
//  ImageLoader
//
//  Created by Hirohisa Kawasaki on 2016/10/31.
//  Copyright © 2016 Hirohisa Kawasaki. All rights reserved.
//

import Foundation
import UIKit

public struct Loadable<Base> {

    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol LoadableCompatible {
    associatedtype CompatibleType

    var load: Loadable<CompatibleType> { get }
}

extension LoadableCompatible {

    public var load: Loadable<Self> {
        return Loadable(self)
    }
}

extension UIImageView: LoadableCompatible {}
