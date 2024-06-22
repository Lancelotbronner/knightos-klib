//
//  BinaryEncodable.swift
//  
//
//  Created by Christophe Bronner on 2024-06-22.
//

public protocol BinaryEncodable {
	associatedtype Failure: Error = Never

	func encode(to encoder: inout BinaryEncoder) throws(Failure)
}
