import Vapor
import Fluent
import Foundation


struct Sock: Model {
	var id: Node?
	var desc: String?
	var img: String?
	var name: String?
	var time: Int?
	var lat: Double?
	var lon: Double?
	var image: String?
	var demouser_id: Node?

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
		image = node["imageName"]?.string
		demouser_id = node["demouser_id"]
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
				"lon" : lon,
				"imageName": image,
				"demouser_id" : demouser_id
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
			socks.double("lat", optional: false)
			socks.double("lon", optional: false)
			socks.string("image", optional: true)
			socks.int("time", optional: true)
			socks.parent(DemoUser.self, optional: false)
			
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
		image = updates.image ?? image
	}
}

extension Sock {
	func user() throws -> Parent<DemoUser> {
		return try parent(demouser_id, nil, DemoUser.self)
	}

func belongs(to: DemoUser) -> Bool {
		return self.demouser_id == to.id
	}

	func distance(lat: Double, lon: Double) -> Double {
		// This is workaround when the GPS location is missing
		guard let localLat = self.lat,
			let localLon = self.lon else {
				return Double(3000000)
		}

		let R = 6371.0
		let dLat = (lat - localLat) * 3.14 / 180
		let dLon = (lon - localLon) * 3.14 / 180
		let latRad1 = localLat * 3.14 / 180
		let latRad2 = lat * 3.14 / 180

		let a1 = sin(dLat/2) * sin(dLat/2)
		let a2 = sin(dLon/2) * sin(dLon/2) * cos(latRad1) * cos(latRad2)

		let a = a1 + a2
		let c = 2 * atan2(sqrt(a),sqrt(1-a))
		return R * c

	}
}
