//
//  BinaryDecoder.swift
//  
//
//  Created by Christophe Bronner on 2024-06-22.
//

public struct BinaryDecoder: ~Copyable {

	public typealias ByteCollection = [UInt8]

	@usableFromInline let bytes: ByteCollection
	@usableFromInline var index: ByteCollection.Index

	@inlinable public init(of bytes: ByteCollection) {
		self.bytes = bytes
		index = bytes.startIndex
	}

	@inlinable public var consumedBytes: ByteCollection.SubSequence {
		bytes[...index]
	}

	@inlinable public var remainingBytes: ByteCollection.SubSequence {
		bytes[index...]
	}

	@inlinable public mutating func skip(_ count: some BinaryInteger) {
		index = bytes.index(index, offsetBy: ByteCollection.Index(count))
	}

	@inlinable public mutating func consume(_ count: some BinaryInteger) -> ByteCollection.SubSequence {
		let anchor = index
		skip(count)
		return bytes[anchor..<index]
	}

}

//MARK: - Result Support

extension BinaryDecoder {

	@inlinable public static func decode<T: BinaryDecodable>(_ type: T.Type, from bytes: [UInt8]) throws(T.Failure) -> T {
		var decoder = BinaryDecoder(of: bytes)
		return try T(from: &decoder)
	}

	@inlinable public static func decode<T: BinaryDecodable>(_ type: T.Type, from bytes: inout [UInt8]) throws(T.Failure) -> T {
		let anchor = bytes.startIndex
		var decoder = BinaryDecoder(of: bytes)
		let value = try T(from: &decoder)
		bytes.removeFirst(bytes.distance(from: anchor, to: decoder.index))
		return value
	}

}

//MARK: - Integer Support

extension BinaryDecoder {

	@inlinable public mutating func decode<I: FixedWidthInteger>(_ type: I.Type) -> I {
		var tmp = I.zero
		withUnsafeMutableBytes(of: &tmp) {
			$0.copyBytes(from: consume(MemoryLayout<I>.size))
		}
		return tmp
	}

	@inlinable public mutating func uint8() -> UInt8 {
		decode(UInt8.self)
	}

}

//MARK: - Collection Support

extension BinaryDecoder {

	@inlinable public mutating func bytes(_ count: some BinaryInteger) -> [UInt8] {
		Array(consume(count))
	}

}

//MARK: - String Support

extension BinaryDecoder {

	@inlinable public mutating func string<E: _UnicodeEncoding>(length: Int, as encoding: E.Type) -> String where E.CodeUnit == UInt8 {
		String(decoding: consume(length), as: E.self)
	}

	@inlinable public mutating func ascii(length: some BinaryInteger) -> String {
		String(decoding: consume(length), as: Unicode.ASCII.self)
	}

	@inlinable public mutating func utf8(length: Int) -> String {
		String(decoding: consume(length), as: Unicode.UTF8.self)
	}

}

//MARK: - Custom Support

extension BinaryDecoder {

	@inlinable public mutating func decode<T: BinaryDecodable>(_ type: T.Type) throws(T.Failure) -> T {
		try T(from: &self)
	}

	//TODO: This seems like a very bad idea
//	@usableFromInline mutating func decode<T: _BitwiseCopyable>(_ type: T.Type) throws -> T {
//		let bytes = consume(MemoryLayout<T>.size)
//		// https://forums.swift.org/t/approaches-for-fixed-size-arrays/58894/108
//		var tmp: T?
//		withUnsafeMutableBytes(of: &tmp) {
//			precondition($0[$0.count - 1] == 1)
//			$0.copyBytes(from: bytes)
//		}
//		precondition(tmp != nil)
//		return tmp!
//	}

}
