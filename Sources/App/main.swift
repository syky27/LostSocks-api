import Vapor
import VaporMySQL

let drop = Droplet(
	availableMiddleware: ["cors" : CorsMiddleware()],
	serverMiddleware: ["file", "cors"],
	preparations: [Sock.self],
	providers: [VaporMySQL.Provider.self])

// MARK: /socks/
drop.grouped(SockURLMiddleware()).resource("socks", SockController())



drop.run()
