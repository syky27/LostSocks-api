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
		try sock.delete()
		return JSON([:])
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

	func toRad(degree: Double) -> Double {
		return (degree * 3.14) / 180
	}


}




extension Request {
	func sock() throws -> Sock {
		guard let json = json else { throw Abort.badRequest }
		return try Sock(node: json)
	}
}
