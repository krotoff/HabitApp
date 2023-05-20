//
//  UserHabit.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSUUID

public struct UserHabit {

    var id: String
    var name: String

    static func makeHabit() -> UserHabit {
        UserHabit(
            id: UUID().uuidString,
            name: L10n.Habit.Editing.Initial.name
        )
    }
}
