//
//  lostsocks.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 19/10/2016.
//
//

import Foundation
import Vapor
import VaporPostgreSQL
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Fluent


func fireUpServer() throws -> Droplet {
	let auth = AuthMiddleware<DemoUser>()


	let drop = Droplet(
		availableMiddleware: ["cors" : CorsMiddleware(), "auth": auth, "trustProxy": TrustProxyMiddleware()],
		serverMiddleware: ["file", "cors", "auth", "trustProxy"],
		preparations: [Sock.self, DemoUser.self, Pivot<Sock, DemoUser>.self],
		providers: [VaporPostgreSQL.Provider.self])


	drop.get("login") { request in
		return try drop.view.make("login")
	}

    drop.get("register") { request in
        return try drop.view.make("register")

    }

	drop.post("login") { request in
		guard let username = request.json?["username"]?.string,
			let password = request.json?["password"]?.string else {
				throw Abort.custom(status: Status.badRequest, message: "You need to provide username and password, in order to register")
		}

		let credentials = UsernamePassword(username: username, password: password)

		do {
			try request.auth.login(credentials)
			_ = try DemoUser.query()
				.filter("username", credentials.username)
				.first()


			return try JSON(node: request.user().makeNode())

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
			return try JSON(node: user.makeNode())
		} catch let e as TurnstileError {
			return try JSON(node: [
				"Exception raised": e.description
				])
		}
	}

	/**
	API Endpoint for /me
	*/
	let protect = ProtectMiddleware(error: Abort.custom(status: .unauthorized, message: "Unauthorized 🖕"))

	drop.grouped(BasicAuthenticationMiddleware(), protect).group("api") { api in
		api.get("me") { request in
			return try JSON(node: request.user().makeNode())
		}


	}

	// MARK: /socks/

	drop.grouped(SockURLMiddleware(), BasicAuthenticationMiddleware(), protect).resource("socks", SockController())
	drop.grouped(BasicAuthenticationMiddleware(), protect).group("socks") {socks in
		socks.get("mine"){request in
			let controller = SockController()
			return try controller.showMine(request: request)
		}

		socks.post("sorted") { request in
			let controller = SockController()
			return try controller.sorted(request: request)
		}

		socks.post("multiple") { request in
			let controller = SockController()
			return try controller.multiple(request: request)
		}

		socks.post(Int.self) { request, sockID in
			let controller = SockController()
			return try controller.upload(request: request, sockID: sockID)

		}

	}




	return drop

}
