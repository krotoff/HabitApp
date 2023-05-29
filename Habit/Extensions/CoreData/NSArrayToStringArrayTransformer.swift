//
//  NSArrayToStringArrayTransformer.swift
//  Habit
//
//  Created by Andrei Krotov on 28/05/2023.
//

import Foundation
import CoreData

@objc(NSArrayToStringArrayTransformer)
class NSArrayToStringArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSArray.self }

    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }

        return NSArray(array: array)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let nsArray = value as? NSArray else { return nil }

        return nsArray.compactMap { $0 as? String }
    }
}

class SecureUnarchiveFromDataTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        // Add the custom classes that your transformable property may contain
        return [NSArray.self]
    }
}
