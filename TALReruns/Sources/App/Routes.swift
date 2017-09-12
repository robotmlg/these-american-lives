import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        /// GET /
        builder.get { request in
            return try SplashController(self.view).getSplashData(request)
        }

        /// GET /calendar/...
        builder.resource("calendar", CalendarController(view))
        
        /// GET /episodes/...
        builder.resource("episodes", EpisodesController(view))
        
        /// GET /about
        builder.get("about") { request in
            return try self.view.make("about")
        }
    }
}
