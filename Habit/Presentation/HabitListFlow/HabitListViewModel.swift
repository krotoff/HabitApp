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
        case deleteCell(IndexPath)
    }

    // MARK: - Private types

    // MARK: - Internal properties

    var models = [UserHabitCell.Model]()

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType

    private let routeListener: ((RouteKind) -> Void)
    private var logicListener: ((LogicEventKind) -> Void)?

    private let onlyTimeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()

    private let wholeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true

        return formatter
    }()

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
        let now = Date().midnight

        models = userHabitsService.habits.map { habit in
            let nextDate = Date(timeInterval: habit.timesForPeriod[0].timeIntervalToAdd, since: now)
            return .init(
                id: habit.id,
                name: habit.name,
                nextDate: L10n.Next.time(wholeDateFormatter.string(from: nextDate)),
                passedCount: 0,
                totalCount: 10,
                action: { [weak self] view in self?.tappedEditing(sourceView: view, habit: habit) },
                deleteAction: { [weak self] in self?.tappedDelete(habitID: habit.id) }
            )
        }
        logicListener?(.update)
    }

    func tappedAdding(sourceView: UIView) {
        routeListener(.editing(sourceView, nil))
    }

    // MARK: - Private methods

    private func tappedEditing(sourceView: UIView, habit: UserHabit) {
        routeListener(.editing(sourceView, habit))
    }

    private func tappedDelete(habitID: String) {
        guard let index = models.firstIndex(where: { $0.id == habitID }) else { return }

        models.remove(at: index)
        logicListener?(.deleteCell(IndexPath(item: index, section: 0)))
    }
}
