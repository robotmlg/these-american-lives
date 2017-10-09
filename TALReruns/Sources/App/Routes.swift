import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    
    let episodeRepo: EpisodeRepository
    let splashController: SplashController
    let calendarController: CalendarController
    let episodesController: EpisodesController
    
    init(_ view: ViewRenderer) {
        self.view = view
        self.episodeRepo = EpisodeRepository()
        self.splashController = SplashController(self.view, repo: episodeRepo)
        self.calendarController = CalendarController(self.view, repo: episodeRepo)
        self.episodesController = EpisodesController(self.view, repo: episodeRepo)
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        /// GET /
        builder.get { request in
            return try self.splashController.getSplashData(request)
        }

        /// GET /calendar/...
        builder.resource("calendar", self.calendarController)
        
        /// GET /episodes/...
        builder.resource("episodes", self.episodesController)
        
        /// GET /about
        builder.get("about") { request in
            return try self.view.make("about")
        }
    }
}
