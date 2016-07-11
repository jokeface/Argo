/// Possible decoding failure reasons.
public enum DecodeError: ErrorProtocol {
  /// The type existing at the key didn't match the type being requested.
  case TypeMismatch(expected: String, actual: String)

  /// The key did not exist in the JSON.
  case MissingKey(String)

  /// A custom error case for adding explicit failure info.
  case Custom(String)

  /// There were multiple errors in the JSON.
  case Multiple([DecodeError])
}

extension DecodeError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .TypeMismatch(expected, actual): return "TypeMismatch(Expected \(expected), got \(actual))"
    case let .MissingKey(s): return "MissingKey(\(s))"
    case let .Custom(s): return "Custom(\(s))"
    case let .Multiple(es): return "Multiple(\(es.map { $0.description }.joined(separator: ", ")))"
    }
  }
}

extension DecodeError: Hashable {
  public var hashValue: Int {
    switch self {
    case let .TypeMismatch(expected: expected, actual: actual):
      return expected.hashValue ^ actual.hashValue
    case let .MissingKey(string):
      return string.hashValue
    case let .Custom(string):
      return string.hashValue
    case let .Multiple(es):
      return es.reduce(0) { $0 ^ $1.hashValue }
    }
  }
}

public func == (lhs: DecodeError, rhs: DecodeError) -> Bool {
  switch (lhs, rhs) {
  case let (.TypeMismatch(expected: expected1, actual: actual1), .TypeMismatch(expected: expected2, actual: actual2)):
    return expected1 == expected2 && actual1 == actual2

  case let (.MissingKey(string1), .MissingKey(string2)):
    return string1 == string2

  case let (.Custom(string1), .Custom(string2)):
    return string1 == string2

  case let (.Multiple(lhs), .Multiple(rhs)):
    return lhs == rhs

  default:
    return false
  }
}

extension DecodeError: Semigroup { }

public func <> (lhs: DecodeError, rhs: DecodeError) -> DecodeError {
  switch (lhs, rhs) {
  case let (.Multiple(es), e): return .Multiple(es + [e])
  case let (e, .Multiple(es)): return .Multiple(es + [e])
  case let (le, re): return .Multiple([le, re])
  }
}
