//
//  HabitListViewModel.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation.NSDate
import UIKit.UIView

final class HabitListViewModel {

    // MARK: - Internal types

    enum RouteKind {
        case editing(UIView, UserHabit?)
    }

    enum LogicEventKind {
        case update
    }

    // MARK: - Private types

    // MARK: - Internal properties

    var models = [UserHabitCell.Model]()

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType

    private let routeListener: ((RouteKind) -> Void)
    private var logicListener: ((LogicEventKind) -> Void)?

    // MARK: - Init

    init(userHabitsService: UserHabitsServiceType, routeListener: @escaping ((RouteKind) -> Void)) {
        self.userHabitsService = userHabitsService
        self.routeListener = routeListener
    }

    // MARK: - Internal methods

    func subscribeForEvents(logicListener: ((LogicEventKind) -> Void)?) {
        self.logicListener = { event in DispatchQueue.main.async { logicListener?(event) } }
    }

    func updateModels() {
        models = userHabitsService.habits.map { habit in
                .init(
                    name: habit.name,
                    action: { [weak self] view in self?.tappedEditing(sourceView: view, habit: habit) }
                )
        }
        logicListener?(.update)
    }

    func tappedAdding(sourceView: UIView) {
        routeListener(.editing(sourceView, nil))
    }

    // MARK: - Private methods

    func tappedEditing(sourceView: UIView, habit: UserHabit) {
        routeListener(.editing(sourceView, habit))
    }
}
