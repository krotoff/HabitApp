//
//  UserHabitsService.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSDate

public protocol UserHabitsServiceType {
    var habits: [UserHabit] { get }

    func updateHabit(_ habit: UserHabit)
}

final class UserHabitsService: UserHabitsServiceType {

    // MARK: - Internal types
    // MARK: - Private types

    // MARK: - Internal properties

    var habits: [UserHabit] = [
        .init(id: "some1", name: "Habit #1", frequency: .daily, timesForPeriod: [.init(hours: 6, minutes: 30)]),
        .init(id: "some2", name: "Habit #2", frequency: .daily, timesForPeriod: [.init(hours: 6, minutes: 30)]),
        .init(id: "some3", name: "Habit #3", frequency: .daily, timesForPeriod: [.init(hours: 6, minutes: 30)]),
    ]

    // MARK: - Private properties

    // MARK: - Init

    init() {

    }

    // MARK: - Internal methods

    func updateHabit(_ habit: UserHabit) {
        if let firstIndex = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[firstIndex] = habit
        } else {
            habits.append(habit)
        }
    }

    // MARK: - Private methods
}
