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

    func fetchData()
    func updateHabit(_ habit: UserHabit)
    func createNewHabit() -> UserHabit
    func deleteHabit(_ habitID: String)
    func subscribeOnChanges(id: String, completion: (() -> Void)?)
    func unsubscribeFromChanges(id: String)
}

final class UserHabitsService: UserHabitsServiceType {

    // MARK: - Internal properties

    var habits = [UserHabit]()

    // MARK: - Private properties

    private let dataGateway: CoreDataGatewayType
    private var subscribes = [String: (() -> Void)?]()

    // MARK: - Init

    init(dataGateway: CoreDataGatewayType) {
        self.dataGateway = dataGateway

        self.dataGateway.subscribeOnChanges(id: String(describing: Self.self)) { [weak self] in
            self?.handleDataUpdates()
        }
    }

    // MARK: - Internal methods

    func fetchData() {
        habits = dataGateway.fetchData()
    }

    func updateHabit(_ habit: UserHabit) {
        dataGateway.saveObject(habit)
    }

    func createNewHabit() -> UserHabit {
        let habit: UserHabit = dataGateway.createObject()
        habits.append(habit)

        return habit
    }

    func deleteHabit(_ habitID: String) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }

        dataGateway.deleteObject(habits[index])
        habits.remove(at: index)
    }

    func subscribeOnChanges(id: String, completion: (() -> Void)?) {
        subscribes[id] = completion
    }

    func unsubscribeFromChanges(id: String) {
        subscribes[id] = nil
    }

    // MARK: - Private methods

    private func handleDataUpdates() {
        let oldHabits = habits
        fetchData()

        if oldHabits != habits {
            subscribes.values.forEach { $0?() }
        }
    }
}
