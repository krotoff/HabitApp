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
    func subscribeOnChanges(id: String, completion: ((CollectionChangeKind) -> Void)?)
    func unsubscribeFromChanges(id: String)
}

final class UserHabitsService: NSObject, UserHabitsServiceType {

    // MARK: - Internal properties

    var habits = [UserHabit]()

    // MARK: - Private properties

    private let dataGateway: CoreDataGatewayType
    private var subscribes = [String: ((CollectionChangeKind) -> Void)?]()
    private let fetchController: NSFetchedResultsController<UserHabit.ManagedObjectType>

    // MARK: - Init

    init(dataGateway: CoreDataGatewayType) {
        self.dataGateway = dataGateway
        fetchController = dataGateway.createFetchResultsController(
            sortDescriptors: [.init(key: #keyPath(UserHabit.ManagedObjectType.createdAt), ascending: true)]
        )

        super.init()

        fetchController.delegate = self
    }

    // MARK: - Internal methods

    func fetchData() {
        do {
            try fetchController.performFetch()
            habits = fetchController.fetchedObjects?.map(UserHabit.init) ?? []
        } catch {
            print(error)
        }
    }

    func updateHabit(_ habit: UserHabit) {
        dataGateway.saveObject(habit)
    }

    func createNewHabit() -> UserHabit {
        dataGateway.createObject()
    }

    func deleteHabit(_ habitID: String) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }

        dataGateway.deleteObject(habits[index])
    }

    func subscribeOnChanges(id: String, completion: ((CollectionChangeKind) -> Void)?) {
        subscribes[id] = completion
    }

    func unsubscribeFromChanges(id: String) {
        subscribes[id] = nil
    }

    // MARK: - Private methods
}

extension UserHabitsService: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        habits = fetchController.fetchedObjects?.map(UserHabit.init) ?? []
        switch type {
        case .insert:
            subscribes.values.forEach { $0?(.insert(newIndexPath!)) }
        case .delete:
            subscribes.values.forEach { $0?(.delete(indexPath!)) }
        case .update:
            subscribes.values.forEach { $0?(.update(indexPath!)) }
        case .move:
            subscribes.values.forEach { $0?(.move(from: indexPath!, to: newIndexPath!)) }
        }
    }
}
