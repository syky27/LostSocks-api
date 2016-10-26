//
//  SockController.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 14/10/2016.
//
//

import HTTP
import Vapor
import Foundation
import CryptoSwift

final class SockController: ResourceRepresentable {

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

	func upload(request: Request, sockID: Int) throws -> ResponseRepresentable {
		guard let image = request.multipart?["image"]?.file else {
			throw Abort.badRequest
		}



		let dataFile = Data(bytes: image.data)
		let imageBase64 = dataFile.base64EncodedString()
		let fileName = NSUUID().uuidString

		guard var sock = try Sock.query().filter("id", String(sockID)).first() else {
			throw Abort.badRequest
		}
		sock.image = imageBase64
		try sock.save()


//		let fileURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName + ".png")
//
//		do {
//			try dataFile.write(to: fileURL, options: .atomic)
//		} catch {
//			print(error)
//		}

//		let client = try! BasicClient(scheme: "https", host: "api.cloudinary.com")
//
//
//		let timestamp = Date().timeIntervalSince1970
//		let strTimestamp = String(timestamp)
//		let apiSecret = "hRt95enlDtgl5ExGDGm7IeXhl1Q"
//		let apiKey = "546779356914594"
//
//		let signature = "public_id=\(fileName)&timestamp=\(strTimestamp)\(apiSecret)".sha1()
//
//		print(strTimestamp)
//		print(signature)
//
//
//		var json = Node([:])
//		json["api_key"] = Node(apiKey)
//		json["public_id"] = Node(fileName)
//		json["timestamp"] = Node(strTimestamp)
//		json["signature"] = Node(signature)
//		json["file"] = Node.bytes(image.data)
//
//		print(image.data)
//
//
//		
//
//
//		return try client.post(path: "/v1_1/lostsocks/image/upload",
//		                       headers: ["Content-Type":"application/json"],
//		                       body: JSON(json).makeBody())


		let client = try! BasicClient(scheme: "https", host: "upload.uploadcare.com")


		var json = Node([:])
		json["UPLOADCARE_PUB_KEY"] = Node("5fed7d0097b425adaa5e")
		json["UPLOADCARE_STORE"] = Node(Int(1))
		json["file"] = Node.bytes(image.data)
		json["jsonerrors"] = Node(Int(1))


		let response = try client.post(path: "/base/",
		                               headers: [:],
		                       body: JSON(json).makeBody())

		print(response)


		return response

	}

}

func shell(args: String...) -> Int32 {
	let task = Process()
	task.launchPath = "/usr/bin/env"
	task.arguments = args
	task.launch()
	task.waitUntilExit()
	return task.terminationStatus
}



extension Request {
	func sock() throws -> Sock {
		guard let json = json else { throw Abort.badRequest }
		return try Sock(node: json)
	}
}
