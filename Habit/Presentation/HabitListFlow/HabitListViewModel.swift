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
        case update(CollectionChangeKind)
    }

    // MARK: - Internal properties

    var headerModel: UserHabitListHeaderView.Model
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

        let today = Date()

        let ttt = 0...1000
        headerModel = UserHabitListHeaderView.Model(
            models: ttt.map { index in
                let date = today.advanced(by: Double(index - 7) * 60 * 60 * 24)
                return UserHabitListDayTrackingCell.Model(
                    date: date,
                    isToday: today.isSameDay(with: date),
                    state: ((index % 4) == 0) ? .normal : .finished,
                    previousDayState: (((index - 1) % 4) == 0) ? .normal : .finished,
                    nextDayState: (((index + 1) % 4) == 0) ? .normal : .finished
                )
            },
            selectedIndex: 5
        )

        userHabitsService.fetchData()
        updateModels(with: .fullReload)

        self.userHabitsService.subscribeOnChanges(id: String(describing: Self.self)) { [weak self] kind in
            self?.updateModels(with: kind)
        }
    }

    // MARK: - Internal methods

    func subscribeForEvents(logicListener: ((LogicEventKind) -> Void)?) {
        self.logicListener = { event in DispatchQueue.main.async { logicListener?(event) } }
    }

    func updateModels(with kind: CollectionChangeKind) {
        let nextDate = Date()

        models = userHabitsService.habits
            .sorted { $0.createdAt < $1.createdAt }
            .map { habit in
                //            let nextDate = Date(timeInterval: habit.timesForPeriod[0].timeIntervalToAdd, since: now)
                return .init(
                    id: habit.id,
                    name: habit.name,
                    nextDate: L10n.Next.time(wholeDateFormatter.string(from: nextDate)),
                    passedCount: [0, 5, 10].randomElement()!,
                    totalCount: 10,
                    action: { [weak self] view in self?.tappedEditing(sourceView: view, habit: habit) },
                    checkAction: nil,
                    deleteAction: { [weak self] in self?.tappedDelete(habitID: habit.id) }
                )
            }
        
        logicListener?(.update(kind))
    }

    func tappedAdding(sourceView: UIView) {
        routeListener(.editing(sourceView, nil))
    }

    // MARK: - Private methods

    private func tappedEditing(sourceView: UIView, habit: UserHabit) {
        routeListener(.editing(sourceView, habit))
    }

    private func tappedDelete(habitID: String) {
        userHabitsService.deleteHabit(habitID)
    }
}
