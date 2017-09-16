//
//  Add.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/15/17.
//
//

import Leaf

final class Inc: Tag {
    let name = "inc"
    
    public enum Error: Swift.Error {
        case expectedTwoArguments
        case invalidArgument(index: Int)
    }
    
    public func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
        guard
            arguments.count == 1,
            let base = arguments[0]?.int
            else { return nil }
        return .string(String(base + 1))
    }
}
