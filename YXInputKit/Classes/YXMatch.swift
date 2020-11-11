//
//  YXTextFiledMatch.swift
//  YXTextField
//
//  Created by 蔡志文 on 2020/5/9.
//  Copyright © 2020 didong. All rights reserved.
//

import Foundation

public protocol Matcher {
    
    var pattern: String { get }

    func match(_ input: String) -> Bool
}

extension Matcher {
    public func match(_ input: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: input)
    }
}

public struct NumberMatch: Matcher {
    
    public var pattern: String { "" }
    
    public var prefix: UInt = 0
    public var suffix: UInt = 0
    
    public init(prefix: UInt, suffix: UInt = 0) {
        self.prefix = prefix
        self.suffix = suffix
    }
    
    public func match(_ input: String) -> Bool {
        
        /// 匹配整数
        if suffix == 0 {
            return matchIntegerValue(input)
        }
        
        /// 匹配浮点数
        return matchFloatValue(input)
    }
    
    private func matchIntegerValue(_ input: String) -> Bool {
        // 整数首位不能为0
        let pattern = #"^\d{0,\#(prefix)}$"#
        if let first = input.first, first != "0" {
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        } else {
            return false
        }
    }
    
    private func matchFloatValue(_ input: String) -> Bool {
        if input.count == 1 && (input == "0" || input == ".") { return true }
        if input.contains(".") {
            let components = input.components(separatedBy: ".")
            if components.count == 2 {
                let prefixValue = components.first!
                let suffixValue = components.last!
                return prefixValue.count <= prefix && suffixValue.count <= suffix
            } else {
                return false
            }
        } else {
            return matchIntegerValue(input)
        }
    }
}

