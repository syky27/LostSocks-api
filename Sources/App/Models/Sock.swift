import Vapor
import Fluent


struct Sock: Model {
	var id: Node?
	var desc: String?
	var img: String?
	var name: String?
	var time: Int?
	var lat: Double?
	var lon: Double?

	var exists: Bool = false

}

// MARK: NodeConvertible

extension Sock: NodeConvertible {
	init(node: Node, in context: Context) throws {
		id = node["id"]
		desc = node["desc"]?.string
		name = node["name"]?.string
		img = node["img"]?.string
		time = node["time"]?.int
		lat = node["lat"]?.double
		lon = node["lon"]?.double
	}

	func makeNode(context: Context) throws -> Node {
		// model won't always have value to allow proper merges,
		// database defaults to false

		return try Node.init(node:
			[
				"id": id,
				"name": name,
				"desc": desc,
				"img": img,
				"time": time,
				"lat" : lat,
				"lon" : lon
			]
		)
	}
}

extension Sock: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create("socks") { socks in
			socks.id()
			socks.string("desc", optional: true)
			socks.string("name", optional: true)
			socks.string("img", optional: true)
			socks.double("lat", optional: true)
			socks.double("lon", optional: true)
			socks.int("time", optional: true)
		}
	}

	static func revert(_ database: Database) throws {
		fatalError("unimplemented \(#function)")
	}
}

extension Sock {
	mutating func merge(updates: Sock) {
		id = updates.id ?? id
		name = updates.name ?? name
		desc = updates.desc ?? desc
		img = updates.img ?? img
		time = updates.time ?? time
		lat = updates.lat ?? lat
		lon = updates.lon ?? lon
	}
}
