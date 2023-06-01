//
//  CoreDataGateway.swift
//  Habit
//
//  Created by Andrei Krotov on 29/05/2023.
//

import Foundation
import CoreData

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
    func subscribeOnChanges(id: String, completion: (() -> Void)?)
    func unsubscribeFromChanges(id: String)
}

public extension NSManagedObject {
    static var entityName: String { String(describing: Self.self) }
}

final class CoreDataGateway: CoreDataGatewayType {

    // MARK: - Private properties

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Habit")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }()
    private var context: NSManagedObjectContext { persistentContainer.viewContext }
    private var subscribes = [String: (() -> Void)?]()

    // MARK: - Init

    init() {
        ValueTransformer.setValueTransformer(SecureUnarchiveFromDataTransformer(), forName: .init("SecureUnarchiveFromDataTransformer"))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: persistentContainer.viewContext
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
        print(#function)
        var managed = ObjectType.ManagedObjectType(context: persistentContainer.viewContext)
        let managable = ObjectType(managedObject: managed)
        managed = managable.updatedManagedObject(managed)

        return managable
    }

    func saveObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        print(#function)
        guard var managed = context.object(with: object.managedObjectID) as? ObjectType.ManagedObjectType else { return }

        managed = object.updatedManagedObject(managed)
        saveContext()
    }

    func deleteObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        print(#function)
        context.delete(context.object(with: object.managedObjectID))
        saveContext()
    }

    func subscribeOnChanges(id: String, completion: (() -> Void)?) {
        subscribes[id] = completion
    }

    func unsubscribeFromChanges(id: String) {
        subscribes[id] = nil
    }

    // MARK: - Private methods

    func someShit() {
        
//        let managedObjectContext = persistentContainer.viewContext
//        let request = NSFetchRequest<TestEntity>(entityName: "TestEntity")
//        let entities = try? managedObjectContext.fetch(request)
//        entities?.forEach {
//            print($0.id, $0.name, $0.value)
//        }


//        let entity = NSEntityDescription.entity(forEntityName: "TestEntity", in: managedObjectContext)!
//        let newObject = NSManagedObject(entity: entity, insertInto: managedObjectContext)
//        newObject.setValue("John Doe2", forKey: "name")
//        newObject.setValue(31, forKey: "value")
//        print(persistentContainer.persistentStoreDescriptions.first?.url)


        // Step 3: Insert the object into the managed object context
//        managedObjectContext.insert(newObject)
//
//        // Step 4: Save the changes
//        do {
//            try managedObjectContext.save()
//            print("Object saved successfully!")
//        } catch {
//            print("Error saving object: \(error.localizedDescription)")
//        }
    }

    func saveContext () {
        print(#function)
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    @objc private func managedObjectContextObjectsDidChange() {
        print(#function)
        subscribes.values.forEach { $0?() }
    }
}
