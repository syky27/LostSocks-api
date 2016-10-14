import Vapor

let drop = Droplet()

drop.post("sock") { request in
	guard let desc = request.data["description"]?.string else {
		throw Abort.badRequest
	}

	guard let name = request.data["name"]?.string else {
		throw Abort.badRequest
	}

	guard let img = request.data["img"]?.string else {
		throw Abort.badRequest
	}

	guard let time = request.data["time"]?.int else {
		throw Abort.badRequest
	}


	return name

}


drop.run()
