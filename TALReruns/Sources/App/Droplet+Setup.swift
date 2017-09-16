@_exported import Vapor

import LeafProvider

extension Droplet {
    public func setup() throws {
        let routes = Routes(view)
        try collection(routes)
        
        if let leaf = self.view as? LeafRenderer {
            leaf.stem.register(Truncate())
        }
    }
}
