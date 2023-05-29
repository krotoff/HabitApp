//
//  HabitEditingViewModel.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import Foundation

final class HabitEditingViewModel {

    // MARK: - Internal types

    enum RouteKind {
        case close
    }

    // MARK: - Private types

    // MARK: - Internal properties

    var model: UserHabit

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType

    private let routeListener: ((RouteKind) -> Void)

    // MARK: - Init

    init(
        userHabitsService: UserHabitsServiceType,
        initialHabit: UserHabit?,
        routeListener: @escaping ((RouteKind) -> Void)
    ) {
        model = initialHabit ?? userHabitsService.createNewHabit()
        self.userHabitsService = userHabitsService
        self.routeListener = { event in DispatchQueue.main.async { routeListener(event) } }
    }

    // MARK: - Internal methods

    func tappedClose() {
        routeListener(.close)
    }

    func updateName(_ name: String) {
        model.name = name
        userHabitsService.updateHabit(model)
    }

    // MARK: - Private methods
}
