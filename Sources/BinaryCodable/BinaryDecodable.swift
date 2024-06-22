//
//  Decodable.swift
//  
//
//  Created by Christophe Bronner on 2024-06-22.
//

public protocol BinaryDecodable {
	associatedtype Failure: Error = Never

	init(from decoder: inout BinaryDecoder) throws(Failure)
}
