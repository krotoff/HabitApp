//
//  UserHabit.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSUUID

public struct UserHabit {

    public enum FrequencyKind {
        case daily
    }

    public struct Time {
        var hours: Int
        var minutes: Int

        var timeIntervalToAdd: TimeInterval { .init(hours * 60 * 60 + minutes * 60) }
    }

    var id: String
    var name: String
    var frequency: FrequencyKind
    var timesForPeriod: [Time]

    static func makeHabit() -> UserHabit {
        UserHabit(
            id: UUID().uuidString,
            name: L10n.Habit.Editing.Initial.name,
            frequency: .daily,
            timesForPeriod: [.init(hours: 6, minutes: 30)]
        )
    }
}
