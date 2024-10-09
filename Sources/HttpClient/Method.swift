//
//  Method.swift
//  klib
//
//  Created by Christophe Bronner on 2024-10-09.
//

public struct HttpMethod: RawRepresentable {
	public let rawValue: String

	@inlinable
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public extension HttpMethod {
	static let get = Self(rawValue: "GET")
	static let query = Self(rawValue: "QUERY")
	static let post = Self(rawValue: "POST")
	static let put = Self(rawValue: "PUT")
	static let delete = Self(rawValue: "DELETE")
}
