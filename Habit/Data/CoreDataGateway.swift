//
//  CoreDataGateway.swift
//  Habit
//
//  Created by Andrei Krotov on 29/05/2023.
//

import Foundation
import CoreData
import UIKit

public enum CollectionChangeKind {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case fullReload
}

public protocol CoreDataFetchManagable: NSManagedObject, NSFetchRequestResult {}

public protocol CoreDataManagable {
    associatedtype ManagedObjectType: NSManagedObject

    var managedObjectID: NSManagedObjectID { get }

    init(managedObject: ManagedObjectType)

    func updatedManagedObject(_ current: ManagedObjectType) -> ManagedObjectType
}

public protocol CoreDataGatewayType {
    func fetchData<ObjectType: CoreDataManagable>() -> [ObjectType]
    func createObject<ObjectType: CoreDataManagable>() -> ObjectType
    func saveObject<ObjectType: CoreDataManagable>(_ object: ObjectType)
    func deleteObject<ObjectType: CoreDataManagable>(_ object: ObjectType)
    func createFetchResultsController<ObjectType: NSManagedObject>(
        sortDescriptors: [NSSortDescriptor]
    ) -> NSFetchedResultsController<ObjectType>
    func saveChangesIfNeeded()
}

public extension NSManagedObject {
    static var entityName: String { String(describing: Self.self) }
}

final class CoreDataGateway: NSObject, CoreDataGatewayType {

    // MARK: - Private properties

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Habit")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }()

    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Init

    override init() {
        super.init()

        ValueTransformer.setValueTransformer(
            SecureUnarchiveFromDataTransformer(),
            forName: .init("SecureUnarchiveFromDataTransformer")
        )
    }

    // MARK: - Internal methods

    func fetchData<ObjectType: CoreDataManagable>() -> [ObjectType] {
        let request = NSFetchRequest<ObjectType.ManagedObjectType>(entityName: ObjectType.ManagedObjectType.entityName)
        do {
            let entities = try persistentContainer.viewContext.fetch(request)

            return entities.map { ObjectType(managedObject: $0) }
        } catch {
            print("#ERR:", self, #function, error)
            return []
        }
    }

    func createObject<ObjectType: CoreDataManagable>() -> ObjectType {
        var managed = ObjectType.ManagedObjectType(context: persistentContainer.viewContext)
        let managable = ObjectType(managedObject: managed)
        managed = managable.updatedManagedObject(managed)

        return managable
    }

    func saveObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        guard var managed = context.object(with: object.managedObjectID) as? ObjectType.ManagedObjectType else { return }

        managed = object.updatedManagedObject(managed)
    }

    func deleteObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        context.delete(context.object(with: object.managedObjectID))
    }

    func createFetchResultsController<ObjectType: NSManagedObject>(
        sortDescriptors: [NSSortDescriptor]
    ) -> NSFetchedResultsController<ObjectType> {
        let request = ObjectType.fetchRequest() as! NSFetchRequest<ObjectType>
        request.sortDescriptors = sortDescriptors

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    func saveChangesIfNeeded() {
        print(#function)
        guard context.hasChanges else { return }

        print(#function, "start saving")
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("#ERR: Unresolved error \(nserror), \(nserror.localizedDescription), \(nserror.userInfo)")
        }
    }

    // MARK: - Private methods

}
