import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        /// GET /
        builder.get("", handler: SplashController(view).getSplashData)

        /// GET /calendar/...
        builder.resource("calendar", CalendarController(view))
        
        /// GET /episodes/...
        builder.resource("episodes", EpisodesController(view))
        
        /// GET /about
    }
}
