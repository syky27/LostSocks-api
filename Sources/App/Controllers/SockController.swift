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
	func index(request: Request) throws -> ResponseRepresentable {
		return try Sock.all().makeNode().converted(to: JSON.self)
	}

	func create(request: Request) throws -> ResponseRepresentable {
		var sock = try request.sock()
		try sock.save()
		return sock
	}

	func show(request: Request, sock: Sock) throws -> ResponseRepresentable {
		return sock
	}

	func delete(request: Request, sock: Sock) throws -> ResponseRepresentable {
		try sock.delete()
		return JSON([:])
	}

	func clear(request: Request) throws -> ResponseRepresentable {
		try Sock.deleteAll()
		return JSON([])
	}

	func update(request: Request, sock: Sock) throws -> ResponseRepresentable {
		let new = try request.sock()
		var sock = sock
		sock.merge(updates: new)
		try sock.save()
		return sock
	}

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

}


extension Request {
	func sock() throws -> Sock {
		guard let json = json else { throw Abort.badRequest }
		return try Sock(node: json)
	}
}
