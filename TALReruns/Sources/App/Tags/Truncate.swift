//
//  Truncate.swift
//  TALReruns
//
//  Created by Matt Goldman on 9/10/17.
//
//

import Leaf

final class Truncate: BasicTag {
    let name = "truncate"
    
    public enum Error: Swift.Error {
        case expectedOneArgument
        case expectedStringArgument
    }
    
    func run(arguments: ArgumentList) throws -> Node? {
        guard arguments.count == 1 else { throw Error.expectedOneArgument }
        guard let value = arguments.first else { return nil }
        guard let string = value.string else { throw Error.expectedStringArgument }
        return .string(string.substring(to: string.index(string.startIndex, offsetBy: 140 < string.characters.count ? 140 : string.characters.count)))
    }
}
