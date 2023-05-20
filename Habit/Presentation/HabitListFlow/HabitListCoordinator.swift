//
//  HabitListCoordinator.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit

import CoordinatorKit
import CoordinatableViewController

final class HabitListCoordinator: Coordinator {

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType

    // MARK: - Init

    init(parentCoordinator: BaseCoordinator, userHabitsService: UserHabitsServiceType) {
        self.userHabitsService = userHabitsService

        super.init(parentCoordinator: parentCoordinator)
    }

    override func makeController() -> CoordinatableViewController {
        let viewModel = HabitListViewModel(userHabitsService: userHabitsService) { [weak self] route in
            switch route {
            case let .editing(habit):
                self?.showEditing(habit: habit)
            }
        }
        return HabitListController(viewModel: viewModel)
    }

    // MARK: - Private methods

    private func showEditing(habit: UserHabit?) {
        guard let controller = controller as? HabitListController else { return }

        let viewToAnimate = UIView()
        viewToAnimate.backgroundColor = controller.addButton.backgroundColor
        viewToAnimate.layer.cornerRadius = controller.addButton.layer.cornerRadius
        controller.view.addSubview(viewToAnimate)
        viewToAnimate.frame = controller.addButton.frame
        
        let presentedViewController = HabitEditingCoordinator(
            parentCoordinator: self,
            userHabitsService: userHabitsService,
            initialHabit: habit
        ).controller
        let destinationFrame = presentedViewController.view.frame

        UIView.animate(withDuration: 0.3, animations: {
            viewToAnimate.frame = destinationFrame
        }) { [weak self] finished in
            guard finished else { return }

            self?.controller.present(presentedViewController, animated: false) {
                viewToAnimate.removeFromSuperview()
            }
        }
    }
}
