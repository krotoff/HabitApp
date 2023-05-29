//
//  UserHabitsService.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSDate
import CoreData
import UIKit

public protocol UserHabitsServiceType {
    var habits: [UserHabit] { get }

    func updateHabit(_ habit: UserHabit)
    func createNewHabit() -> UserHabit
}

final class UserHabitsService: UserHabitsServiceType {

    // MARK: - Internal types
    // MARK: - Private types

    // MARK: - Internal properties

    var habits: [UserHabit]

    // MARK: - Private properties

    private let context: NSManagedObjectContext

    // MARK: - Init

    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        habits = [
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
//            .init(context: context),
        ]
    }

    // MARK: - Internal methods

    func updateHabit(_ habit: UserHabit) {
        if let firstIndex = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[firstIndex] = habit
        } else {
            habits.append(habit)
        }

        do {
            try habit.save(in: context)
        } catch {
            print("err", error)
        }
    }

    func createNewHabit() -> UserHabit {
        UserHabit(context: context)
    }

    // MARK: - Private methods
}
