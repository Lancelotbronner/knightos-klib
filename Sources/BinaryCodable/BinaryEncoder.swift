//
//  BinaryEncoder.swift
//  
//
//  Created by Christophe Bronner on 2024-06-22.
//

public struct BinaryEncoder: ~Copyable {

	public typealias ByteCollection = [UInt8]

	public var bytes: ByteCollection = []

	@inlinable public init() { }

}

//MARK: - Result Support

extension BinaryEncoder {

	@inlinable public static func encode<T: BinaryEncodable>(_ value: T) throws(T.Failure) -> [UInt8] {
		var encoder = BinaryEncoder()
		try value.encode(to: &encoder)
		return encoder.bytes
	}

	@inlinable public static func encode<T: BinaryEncodable>(_ value: T, into bytes: inout [UInt8]) throws(T.Failure) {
		var encoder = BinaryEncoder()
		try value.encode(to: &encoder)
		bytes.append(contentsOf: encoder.bytes)
	}

}

//MARK: - Integer Support

extension BinaryEncoder {

	@inlinable public mutating func encode(_ value: some FixedWidthInteger) {
		withUnsafeBytes(of: value) {
			bytes.append(contentsOf: $0)
		}
	}

	@inlinable public mutating func uint8(_ value: some BinaryInteger) {
		bytes.append(UInt8(value))
	}

}

//MARK: - Collection Support

extension BinaryEncoder {

	@inlinable public mutating func bytes(_ count: some Sequence<UInt8>) {
		bytes.append(contentsOf: count)
	}

}

//MARK: - String Support

extension BinaryEncoder {

	@inlinable public mutating func string<E: Unicode.Encoding>(_ value: String, as encoding: E.Type) {
		//TODO: Encode the string
	}

	@inlinable public mutating func ascii(_ value: String) {
		bytes.append(contentsOf: value.compactMap(\.asciiValue))
	}

	@inlinable public mutating func ascii<I: FixedWidthInteger>(_ value: String, length: I.Type) {
		let value = value.compactMap(\.asciiValue)
		encode(I(value.count))
		bytes.append(contentsOf: value)
	}

	@inlinable public mutating func utf8(_ value: String) {
		bytes.append(contentsOf: value.utf8)
	}

	@inlinable public mutating func utf8<I: FixedWidthInteger>(_ value: String, length: I.Type) {
		let value = value.utf8
		encode(I(value.count))
		bytes.append(contentsOf: value)
	}

}

//MARK: - Custom Support

extension BinaryEncoder {

	@inlinable public mutating func encode<T: BinaryEncodable>(_ value: T) throws(T.Failure) {
		try value.encode(to: &self)
	}

}
