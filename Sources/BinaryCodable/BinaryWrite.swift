//
//  BinaryWritable.swift
//  
//
//  Created by Christophe Bronner on 2024-06-20.
//

//MARK: - Codable

public protocol BinaryWritable {
	func write(to bytes: inout [UInt8])
}

extension BinaryWritable {

	@inlinable public var bytes: [UInt8] {
		var bytes: [UInt8] = []
		write(to: &bytes)
		return bytes
	}

}

//MARK: - Coder

//MARK: - Builder

public protocol BinaryWriter: BinaryWritable {
	associatedtype Writer: BinaryWriter
	@BinaryWriterBuilder var binaryWriter: Writer { get }
}

extension BinaryWriter {

	@inlinable public func write(to bytes: inout [UInt8]) {
		binaryWriter.write(to: &bytes)
	}

}

@resultBuilder
public struct BinaryWriterBuilder {

	public struct Component: BinaryWriter {
		@usableFromInline let _write: (inout [UInt8]) -> Void

		@usableFromInline init(write: @escaping (inout [UInt8]) -> Void) {
			_write = write
		}

		@_transparent public var binaryWriter: Self { self }

		@inlinable public func write(to bytes: inout [UInt8]) {
			_write(&bytes)
		}
	}

	@inlinable public static func buildExpression(_ expression: some BinaryWritable) -> Component {
		Component(write: expression.write)
	}

	@inlinable public static func buildExpression(_ expressions: some Sequence<some BinaryWritable>) -> Component {
		Component {
			for expression in expressions {
				expression.write(to: &$0)
			}
		}
	}

	@inlinable public static func buildExpression(_ expression: UInt8) -> Component {
		Component {
			$0.append(expression)
		}
	}

	@inlinable public static func buildExpression(_ expression: some Sequence<UInt8>) -> Component {
		Component {
			$0.append(contentsOf: expression)
		}
	}

	@inlinable public static func buildExpression(_ expression: some FixedWidthInteger) -> Component {
		Component { bytes in
			withUnsafeBytes(of: expression) {
				bytes.append(contentsOf: $0)
			}
		}
	}

	@inlinable public static func buildBlock() -> Component {
		Component { _ in }
	}

	@inlinable public static func buildBlock(_ components: Component...) -> Component {
		Component {
			for component in components {
				component.write(to: &$0)
			}
		}
	}

	@inlinable static func buildOptional(_ component: Component?) -> Component {
		component ?? Component { _ in }
	}

	@inlinable static func buildEither(first component: Component) -> Component {
		component
	}

	@inlinable static func buildEither(second component: Component) -> Component {
		component
	}

	@inlinable static func buildLimitedAvailability(_ component: Component) -> Component {
		component
	}

	@inlinable public static func buildArray(_ components: [Component]) -> Component {
		Component {
			for component in components {
				component.write(to: &$0)
			}
		}
	}

	@inlinable public static func buildFinalResult(_ component: Component) -> Component {
		component
	}

//	@inlinable public static func buildFinalResult(_ component: Component) -> [UInt8] {
//		component.bytes
//	}

}
