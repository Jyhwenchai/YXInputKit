//
//  FirstDifferenceBetweenStrings.swift
//  test-swift
//
//  Created by 蔡志文 on 2020/5/18.
//  Copyright © 2020 蔡志文. All rights reserved.
//

import Foundation

internal enum DifferenceResult {
    case noDifference
    case differenceAtIndex(Int)
}

internal func firstDifferenceBetweenStrings(s1: String, s2: String) -> DifferenceResult {

    let length1 = s1.count
    let length2 = s2.count
    
    let lenMin = min(length1, length2)
    
    for i in 0..<lenMin {
        let l = String(s1[s1.startIndex...s1.index(s1.startIndex, offsetBy: i)])
        let r = String(s2[s2.startIndex...s2.index(s2.startIndex, offsetBy: i)])
        if l != r {
            return .differenceAtIndex(i)
        }
    }
    
    if length1 < length2 {
        return .differenceAtIndex(length1)
    }
    
    if length2 < length1 {
        return .differenceAtIndex(length2)
    }
    
    return .noDifference
}
