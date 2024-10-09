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
	var url: URL { get }
}
