//
//  UserHabit.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSUUID
import CoreData

public struct UserHabit {

    public enum FrequencyKind: String {
        case daily
    }

    public struct Time {
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

    var id: String
    var name: String = L10n.Habit.Editing.Initial.name
    var frequency: FrequencyKind = .daily
    var timesForPeriod: [Time] = []

    private var managedObject: UserHabitMO

    init(context: NSManagedObjectContext) {
        let object = UserHabitMO(context: context)

        self.init(managed: object)
    }

    init(managed: UserHabitMO) {
        managedObject = managed

        if let id = managed.id {
            self.id = id.uuidString
        } else {
            let uuid = UUID()
            managedObject.id = uuid
            id = uuid.uuidString
        }

        if let name = managed.name {
            self.name = name
        } else {
            let name = L10n.Habit.Editing.Initial.name
            managedObject.name = name
            self.name = name
        }

        if let frequency = managed.frequency {
            self.frequency = FrequencyKind(rawValue: frequency) ?? .daily
        } else {
            frequency = .daily
            managedObject.frequency = FrequencyKind.daily.rawValue
        }

        if let timesForPeriod = managed.timesForPeriod as? [String] {
            self.timesForPeriod = timesForPeriod.compactMap { Time(string: $0) }
        } else {
            self.timesForPeriod = []
            managedObject.timesForPeriod = [String]() as NSObject
        }

        if managed.createdAt == nil {
            managedObject.createdAt = Date()
        }

        print("created", managedObject)
    }
}

public extension UserHabit {

    func save(in context: NSManagedObjectContext) throws {
        managedObject.name = name
        managedObject.frequency = frequency.rawValue
        managedObject.timesForPeriod = timesForPeriod.map(\.toString) as NSObject

        if context.registeredObject(for: managedObject.objectID) == nil {
            context.insert(managedObject)
        }
        print(self)
        try context.save()
    }
}
