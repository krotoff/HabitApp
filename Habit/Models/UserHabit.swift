//
//  UserHabit.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSUUID
import CoreData

public struct UserHabit: Equatable {

    public enum FrequencyKind: String {
        case daily
    }

    public struct Time: Equatable {
        var hours: Int
        var minutes: Int

        var timeIntervalToAdd: TimeInterval { .init(hours * 60 * 60 + minutes * 60) }
        var toString: String { "\(hours):\(minutes)" }

        init(hours: Int, minutes: Int) {
            self.hours = hours
            self.minutes = minutes
        }

        init?(string: String) {
            let splitted = string.split(separator: ":").compactMap { Int($0) }

            guard splitted.count == 2 else { return nil }

            (self.hours, self.minutes) = (splitted[0], splitted[1])
        }
    }

    var id: String = UUID().uuidString
    var name: String = L10n.Habit.Editing.Initial.name
    var frequency: FrequencyKind = .daily
    var timesForPeriod: [Time] = []
    var createdAt: Date = Date()

    public var managedObjectID: NSManagedObjectID

    public init(managedObject: UserHabitMO) {
        self.managedObjectID = managedObject.objectID

        if let id = managedObject.id {
            self.id = id.uuidString
        }

        if let name = managedObject.name {
            self.name = name
        }

        if let frequency = managedObject.frequency {
            self.frequency = FrequencyKind(rawValue: frequency) ?? .daily
        }

        if let timesForPeriod = managedObject.timesForPeriod as? [String] {
            self.timesForPeriod = timesForPeriod.compactMap { Time(string: $0) }
        }

        if let createdAt = managedObject.createdAt {
            self.createdAt = createdAt
        }
    }
}

extension UserHabit: CoreDataManagable {
    public func updatedManagedObject(_ current: UserHabitMO) -> UserHabitMO {
        current.id = UUID(uuidString: id)
        current.name = name
        current.frequency = frequency.rawValue
        current.timesForPeriod = timesForPeriod.map(\.toString) as NSObject
        current.createdAt = createdAt

        return current
    }
}
