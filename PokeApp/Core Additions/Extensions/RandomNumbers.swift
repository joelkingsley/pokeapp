//
//  RandomNumbers.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 27/08/21.
//

import Foundation

extension Int {

    static func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        if max >= min {
            var set = Set<Int>()
            while (set.count < count) || (set.count < max-min+1) {
                set.insert(Int.random(in: min...max))
            }
            return Array(set)
        } else {
            return [Int]()
        }
    }

}
