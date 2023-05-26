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

    // MARK: - Internal types

    struct Source {
        let frame: CGRect
        let cornerRadius: CGFloat
    }

    // MARK: - Private properties

    private let userHabitsService: UserHabitsServiceType
    private let initialHabit: UserHabit?
    private let source: Source

    // MARK: - Init

    init(
        parentCoordinator: BaseCoordinator,
        userHabitsService: UserHabitsServiceType,
        initialHabit: UserHabit?,
        source: Source
    ) {
        self.userHabitsService = userHabitsService
        self.initialHabit = initialHabit
        self.source = source

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
            var viewToAnimate = controller.view.snapshotView(afterScreenUpdates: false)
        else { return }
        
        viewToAnimate = UIView()
        viewToAnimate.backgroundColor = controller.view.backgroundColor
        viewToAnimate.layer.masksToBounds = true
        viewToAnimate.layer.cornerRadius = source.cornerRadius
        controller.view.isHidden = true
        presenting.view.addSubview(viewToAnimate)
        viewToAnimate.frame = presenting.view.frame

        let destinationFrame = source.frame
        
        UIView.animate(
            withDuration: 0.3,
            animations: { viewToAnimate.frame = destinationFrame },
            completion: { _ in
                controller.dismiss(animated: false) {
                    controller.view.isHidden = false
                    viewToAnimate.removeFromSuperview()
                }
            }
        )
    }
}
