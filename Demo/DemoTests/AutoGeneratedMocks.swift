// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import Combine

@testable import XConfigs

public class MockKeyValueProvider: KeyValueProvider {
    public init() {}

    // MARK: - provide

    public var provideThrowableError: Error?
    public var provideCallsCount = 0
    public var provideCalled: Bool {
        provideCallsCount > 0
    }

    public var provideReturnValue: [String: Any]!
    public var provideClosure: (() async throws -> [String: Any])?

    public func provide() async throws -> [String: Any] {
        if let error = provideThrowableError {
            throw error
        }
        provideCallsCount += 1
        if let provideClosure = provideClosure {
            return try await provideClosure()
        } else {
            return provideReturnValue
        }
    }
}

public class MockKeyValueStore: KeyValueStore {
    public init() {}

    // MARK: - get<Value: RawStringValueRepresentable>

    public var getForCallsCount = 0
    public var getForCalled: Bool {
        getForCallsCount > 0
    }

    public var getForReceivedKey: String?
    public var getForReceivedInvocations: [String] = []
    public var getForReturnValue: Value?
    public var getForClosure: ((String) -> Value?)?

    public func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        getForCallsCount += 1
        getForReceivedKey = key
        getForReceivedInvocations.append(key)
        if let getForClosure = getForClosure {
            return getForClosure(key)
        } else {
            return getForReturnValue
        }
    }

    // MARK: - set<Value: RawStringValueRepresentable>

    public var setValueForCallsCount = 0
    public var setValueForCalled: Bool {
        setValueForCallsCount > 0
    }

    public var setValueForReceivedArguments: (value: Value, key: String)?
    public var setValueForReceivedInvocations: [(value: Value, key: String)] = []
    public var setValueForClosure: ((Value, String) -> Void)?

    public func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        setValueForCallsCount += 1
        setValueForReceivedArguments = (value: value, key: key)
        setValueForReceivedInvocations.append((value: value, key: key))
        setValueForClosure?(value, key)
    }

    // MARK: - remove

    public var removeKeyCallsCount = 0
    public var removeKeyCalled: Bool {
        removeKeyCallsCount > 0
    }

    public var removeKeyReceivedKey: String?
    public var removeKeyReceivedInvocations: [String] = []
    public var removeKeyClosure: ((String) -> Void)?

    public func remove(key: String) {
        removeKeyCallsCount += 1
        removeKeyReceivedKey = key
        removeKeyReceivedInvocations.append(key)
        removeKeyClosure?(key)
    }
}
