//
//  SockController.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 14/10/2016.
//
//

import HTTP
import Vapor

final class SockController: ResourceRepresentable {

	class func setup() {
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
			
		}
	}

	func validate(request: Request) throws -> Bool {
		let user = try request.user()
		let sock = try request.sock()
		return sock.belongs(to: user)

	}

	// GET [/socks]
	func index(request: Request) throws -> ResponseRepresentable {
		return try Sock.all().makeNode().converted(to: JSON.self)
	}

	// POST [/socks]
	func create(request: Request) throws -> ResponseRepresentable {
		let user  = try request.user()
		var sock = try request.sock()
		sock.demouser_id = user.id
		try sock.save()
		return sock
	}

	// GET [/socks/1]
	func show(request: Request, sock: Sock) throws -> ResponseRepresentable {
		return sock
	}

	// DELETE [/socks/1]
	func delete(request: Request, sock: Sock) throws -> ResponseRepresentable {
		print("Enter delete")

		let user = try request.user()
		if sock.demouser_id == user.id {
			print("User Check success")
			try sock.delete()
			return JSON([:])
		}
		
		return JSON(["Forbidden" : "That sock aint yours to modify"])
	}

	// DELETE [/socks]
	func clear(request: Request) throws -> ResponseRepresentable {
		try Sock.deleteAll()
		return JSON([])
	}

	// PATCH [/socks/1]
	func update(request: Request, sock: Sock) throws -> ResponseRepresentable {
		let new = try request.sock()
		var sock = sock
		sock.merge(updates: new)
		try sock.save()
		return sock
	}

	// PUT [/socks/1]
	func replace(request: Request, sock: Sock) throws -> ResponseRepresentable {
		try sock.delete()
		return try create(request: request)
	}

	func makeResource() -> Resource<Sock> {
		return Resource(
			index: index,
			store: create,
			show: show,
			replace: replace,
			modify: update,
			destroy: delete,
			clear: clear
		)
	}

	// MARK: Custom endpoints
	func showMine(request: Request) throws -> ResponseRepresentable {
		let user = try request.user()
		return try Sock.query().filter("demouser_id", user.id!).run().makeNode().converted(to: JSON.self)
	}

	func sorted(request: Request) throws -> ResponseRepresentable {
		guard let lat = request.json?["lat"]?.double,
			let lon = request.json?["lon"]?.double else {
			throw Abort.badRequest
		}

		let socks = try Sock.all().sorted {
			$0.distance(lat: lat, lon: lon) < $1.distance(lat: lat, lon: lon)
		}
		
		return try socks.makeNode().converted(to: JSON.self)
	}

	func multiple(request: Request) throws -> ResponseRepresentable {
		do {
			var entryCounter = 0
			guard let array = request.json?.makeNode().nodeArray else {
				throw Abort.badRequest
			}

			for object in array {
				var new = try Sock(node: object)
				let user = try request.user()
				new.demouser_id = user.id
				try new.save()
				entryCounter += 1
			}

			return try JSON(node: ["Total Number of Entries Accepted": entryCounter])

		} catch(let e){
			return try! JSON(node: ["Exception Raised":e.localizedDescription])
		}
	}

}

extension Request {
	func sock() throws -> Sock {
		guard let json = json else { throw Abort.badRequest }
		return try Sock(node: json)
	}
}
