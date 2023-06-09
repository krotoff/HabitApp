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
            case let .editing(sourceView, habit):
                self?.showEditing(sourceView: sourceView, habit: habit)
            }
        }
        return HabitListController(viewModel: viewModel)
    }

    // MARK: - Private methods

    private func showEditing(sourceView: UIView, habit: UserHabit?) {
        guard let controller = controller as? HabitListController else { return }

        let viewToAnimate = UIView()
        viewToAnimate.backgroundColor = sourceView.backgroundColor
        viewToAnimate.layer.cornerRadius = sourceView.layer.cornerRadius
        controller.view.addSubview(viewToAnimate)

        let cellFrameInSuperview = sourceView.superview?.convert(sourceView.frame, to: sourceView.superview?.superview)
        let cellFrameInViewController = controller.view.convert(cellFrameInSuperview!, from: sourceView.superview?.superview)

        viewToAnimate.frame = cellFrameInViewController
        
        let presentedViewController = HabitEditingCoordinator(
            parentCoordinator: self,
            userHabitsService: userHabitsService,
            initialHabit: habit,
            source: .init(frame: viewToAnimate.frame, cornerRadius: viewToAnimate.layer.cornerRadius)
        ).controller
        let destinationFrame = presentedViewController.view.frame

        UIView.animate(withDuration: 0.33, animations: {
            viewToAnimate.frame = destinationFrame
        }) { [weak self] finished in
            guard finished else { return }

            self?.controller.present(presentedViewController, animated: false) {
                viewToAnimate.removeFromSuperview()
            }
        }
    }
}
