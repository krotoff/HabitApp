//
//  HabitEditingCoordinator.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit

import CoordinatorKit
import CoordinatableViewController

final class HabitEditingCoordinator: Coordinator {

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType
    private let initialHabit: UserHabit?

    // MARK: - Init

    init(parentCoordinator: BaseCoordinator, userHabitsService: UserHabitsServiceType, initialHabit: UserHabit?) {
        self.userHabitsService = userHabitsService
        self.initialHabit = initialHabit

        super.init(parentCoordinator: parentCoordinator)
    }

    override func makeController() -> CoordinatableViewController {
        let viewModel = HabitEditingViewModel(
            userHabitsService: userHabitsService,
            initialHabit: initialHabit
        ) { [weak self] event in
            switch event {
            case .close:
                self?.dismiss()
            }
        }

        return HabitEditingController(viewModel: viewModel)
    }

    // MARK: - Private methods

    private func dismiss() {
        guard
            let controller = controller as? HabitEditingController,
            let presenting = controller.presentingViewController as? HabitListController,
            let viewToAnimate = controller.view.snapshotView(afterScreenUpdates: false)
        else { return }

        viewToAnimate.layer.masksToBounds = true
        viewToAnimate.layer.cornerRadius = presenting.addButton.layer.cornerRadius
        controller.view.isHidden = true
        presenting.view.addSubview(viewToAnimate)
        viewToAnimate.frame = presenting.view.frame

        let destinationFrame = presenting.addButton.frame
        
        UIView.animate(withDuration: 0.3, animations: {
            viewToAnimate.frame = destinationFrame
        }) { _ in
            controller.dismiss(animated: false) {
                controller.view.isHidden = false
                viewToAnimate.removeFromSuperview()
            }
        }
    }
}
