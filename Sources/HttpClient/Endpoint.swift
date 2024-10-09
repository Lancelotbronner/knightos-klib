//
//  Endpoint.swift
//  klib
//
//  Created by Christophe Bronner on 2024-10-09.
//

import Foundation

public protocol Endpoint<Response>: Decodable {
	associatedtype Response: Encodable

	var method: HttpMethod { get }
	var path: String { get }
	var query: [URLQueryItem]? { get }
}

public extension Endpoint {

	@inlinable
	var query: [URLQueryItem]? { nil }

	@inlinable
	func url(from baseURL: URL) -> URL {
		if let query {
			var components = URLComponents()
			components.path = path
			components.queryItems = query
			return components.url(relativeTo: baseURL)!
		}
		if #available(macOS 13.0, *) {
			return URL(filePath: path, relativeTo: baseURL)
		} else {
			return URL(fileURLWithPath: path, relativeTo: baseURL)
		}
	}
}
