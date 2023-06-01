//
//  AppCoordinator.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit.UIWindow

import CoordinatorKit

final class AppCoordinator: BaseCoordinator {

    // MARK: - Internal types
    // MARK: - Private types

    // MARK: - Internal properties
    // MARK: - Private properties

    private let window: UIWindow

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window

        super.init()
    }

    // MARK: - Internal methods

    func startApp() {
        startTestFlow(on: nil)
    }

    // MARK: - Private methods

    private func startTestFlow(on controller: UIViewController?) {
        let coordinator = HabitListCoordinator(
            parentCoordinator: self,
            userHabitsService: UserHabitsService(dataGateway: CoreDataGateway())
        )

        if let controller {
            controller.present(coordinator.controller, animated: true)
        } else {
            setControllerAsRoot(coordinator.controller)
        }
    }

    private func setControllerAsRoot(_ controller: UIViewController) {
        window.rootViewController = controller
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: nil)
        window.makeKeyAndVisible()
    }
}
