//
//  Json.swift
//  
//
//  Created by Christophe Bronner on 2024-06-15.
//

//MARK: - Json

@dynamicMemberLookup
public enum Json {
	case string(String)
	case integer(Int)
	case number(Double)
	case boolean(Bool)
	case null
	case array([Json])
	case object([String : Json])
	case undefined([any CodingKey])
}

//MARK: - Value Access

public extension Json {

	subscript(position: Int) -> Json {
		_read {
			if case .array(let value) = self, value.indices.contains(position) {
				yield value[position]
				return
			}
			yield .undefined([AnyCodingKey(intValue: position)])
		}
	}

	subscript(key: String) -> Json {
		_read {
			var defaultValue: Json {
				.undefined([AnyCodingKey(stringValue: key)])
			}
			if case .object(let value) = self, value.keys.contains(key) {
				yield value[key, default: defaultValue]
				return
			}
			yield defaultValue
		}
	}

	subscript(dynamicMember dynamicMember: String) -> Json {
		_read { yield self[dynamicMember] }
	}

	var isString: Bool {
		switch self {
		case .string: true
		default: false
		}
	}

	var stringValue: String {
		switch self {
		case .string(let value): value
		case .integer(let value): "\(value)"
		case .number(let value): "\(value)"
		case .boolean(let value): "\(value)"
		default: ""
		}
	}

	var isNumber: Bool {
		switch self {
		case .number, .integer: true
		default: false
		}
	}

	var doubleValue: Double {
		switch self {
		case .string(let value): Double(value) ?? 0.0
		case .number(let value): value
		case .integer(let value): Double(value)
		default: 0.0
		}
	}

	var intValue: Int {
		switch self {
		case .string(let value): Int(value) ?? 0
		case .number(let value): Int(value)
		case .integer(let value): value
		default: 0
		}
	}

	var isBoolean: Bool {
		switch self {
		case .boolean: true
		default: false
		}
	}

	var boolValue: Bool {
		switch self {
		case .string(let value): !value.isEmpty
		case .number(let value): value != 0
		case .integer(let value): value != 0
		case .boolean(let value): value
		case .array(let value): !value.isEmpty
		case .object(let value): !value.isEmpty
		default: false
		}
	}

	var isNull: Bool {
		switch self {
		case .null: return true
		default: return false
		}
	}

	var isArray: Bool {
		switch self {
		case .array: return true
		default: return false
		}
	}

	var arrayValue: [Json] {
		switch self {
		case .array(let value): return value
		default: return []
		}
	}

	var isObject: Bool {
		switch self {
		case .object: return true
		default: return false
		}
	}

	var objectValue: [String : Json] {
		switch self {
		case .object(let value): return value
		default: return [:]
		}
	}

	var isUndefined: Bool {
		switch self {
		case .undefined: return true
		default: return false
		}
	}

}

//MARK: - Collection

public extension Json {

	func firstValue(where predicate: (Json) throws -> Bool) rethrows -> Json {
		try arrayValue.first(where: predicate) ?? .undefined([])
	}

}

//MARK: - Codable

extension Json: Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let string = try? container.decode(String.self) {
			self = .string(string)
		} else if let integer = try? container.decode(Int.self) {
			self = .integer(integer)
		} else if let number = try? container.decode(Double.self) {
			self = .number(number)
		} else if container.decodeNil() {
			self = .null
		} else if let bool = try? container.decode(Bool.self) {
			self = .boolean(bool)
		} else if let array = try? container.decode([Json].self) {
			self = .array(array)
		} else if let object = try? container.decode([String : Json].self) {
			self = .object(object)
		} else {
			self = .undefined(container.codingPath)
		}
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .string(let value): try container.encode(value)
		case .integer(let value): try container.encode(value)
		case .number(let value): try container.encode(value)
		case .null: try container.encodeNil()
		case .boolean(let value): try container.encode(value)
		case .array(let value): try container.encode(value)
		case .object(let value): try container.encode(value)
		case .undefined: break
		}
	}
}

enum AnyCodingKey: CodingKey {
	case index(Int)
	case key(String)

	init(stringValue: String) {
		self = .key(stringValue)
	}

	var stringValue: String {
		switch self {
		case .index(let i): i.description
		case .key(let k): k
		}
	}

	init(intValue: Int) {
		self = .index(intValue)
	}

	var intValue: Int? {
		switch self {
		case .index(let i): i
		case .key(let k): nil
		}
	}
}
