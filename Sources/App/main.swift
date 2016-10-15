import Vapor
import VaporMySQL
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Fluent
import Foundation

let auth = AuthMiddleware<DemoUser>()

let drop = Droplet(
	availableMiddleware: ["cors" : CorsMiddleware(), "auth": auth, "trustProxy": TrustProxyMiddleware()],
	serverMiddleware: ["file", "cors", "auth", "trustProxy"],
	preparations: [Sock.self, DemoUser.self],
	providers: [VaporMySQL.Provider.self])

// MARK: /socks/
drop.grouped(SockURLMiddleware()).resource("socks", SockController())


drop.get("login") { request in
	return try drop.view.make("login")
}

drop.post("login") { request in
	guard let username = request.json?["username"]?.string,
		let password = request.json?["password"]?.string else {
			throw Abort.custom(status: Status.badRequest, message: "You need to provide username and password, in order to register")
	}

	let credentials = UsernamePassword(username: username, password: password)

	do {
		try request.auth.login(credentials)
		let fetchedUser = try DemoUser.query()
			.filter("username", credentials.username)
			.first()


		return fetchedUser!.json()
	} catch let e {
		return try JSON(node: [
			"Exception raised": e.localizedDescription
			])
	}
}

drop.post("register") { request in

	guard let username = request.json?["username"]?.string,
		let password = request.json?["password"]?.string else {
			throw Abort.custom(status: Status.badRequest, message: "You need to provide username and password, in order to register")
	}


	let credentials = UsernamePassword(username: username, password: password)

	do {
		let user = try DemoUser.register(credentials: credentials)
		try request.auth.login(credentials)
		return Response(redirect: "/")
	} catch let e as TurnstileError {
		return try JSON(node: [
			"Exception raised": e.description
			])
	}
}

/**
API Endpoint for /me
*/
let protect = ProtectMiddleware(error: Abort.custom(status: .unauthorized, message: "Unauthorized"))

drop.grouped(BasicAuthenticationMiddleware(), protect).group("api") { api in
	api.get("me") { request in
		return try JSON(node: request.user().makeNode())
	}
}


drop.run()
