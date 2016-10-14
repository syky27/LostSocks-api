//
//  Fluent+Utilities.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 14/10/2016.
//
//

import Fluent

extension Entity {
	static func deleteAll() throws {
		try Self.query().delete()
	}
}
