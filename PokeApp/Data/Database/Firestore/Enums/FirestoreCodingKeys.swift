//
//  FirestoreCodingKeys.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 26/08/21.
//

import Foundation

enum DocumentCodingKeys: String, CodingKey {
    case name, createTime, updateTime
    case fields
}

enum StringValueCodingKeys: String, CodingKey {
    case stringValue
}

enum IntValueCodingKeys: String, CodingKey {
    case integerValue
}

enum BoolValueCodingKeys: String, CodingKey {
    case booleanValue
}
