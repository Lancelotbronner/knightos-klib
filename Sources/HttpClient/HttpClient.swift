//
//  HttpClient.swift
//  klib
//
//  Created by Christophe Bronner on 2024-10-09.
//

import Foundation

public struct HttpClient {
	public let baseURL: URL
	public let session: URLSession

	public init(at url: URL, session: URLSession = .shared) {
		self.baseURL = url
		self.session = session
	}
}

public extension HttpClient {

	func send<Request: Endpoint>(_ request: Request) async throws -> Request.Response {

	}

}
