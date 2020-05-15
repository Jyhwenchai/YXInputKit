//
//  DelegateRelay.swift
//  Pods-YXInputKit_Example
//
//  Created by 蔡志文 on 2020/5/14.
//

import Foundation

internal class DelegateRelay: NSObject {

    private(set) weak var realDelegate: AnyObject?
    init(realDelegate: AnyObject?) {
        self.realDelegate = realDelegate
        
    }
}
