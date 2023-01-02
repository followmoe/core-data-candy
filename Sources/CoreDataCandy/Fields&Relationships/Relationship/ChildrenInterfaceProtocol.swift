//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

/// Holds the logic to access a children (one to many) relationship
public protocol ChildrenInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ChildModel: DatabaseModel
    associatedtype MutableStorage: RelationMutableStorage

    var keyPath: ReferenceWritableKeyPath<Entity, MutableStorage.Immutable?> { get }
}

extension ChildrenInterfaceProtocol {

    public func mutableStorage(from entity: Entity) -> MutableStorage {
        guard let children = entity[keyPath: keyPath]?.mutableCopy() as? MutableStorage else {
            assertionFailure("Unable to get a 'NSMutableSet' from the 'NSSet' for \(String(describing: Entity.self)) \(String(describing: ChildModel.self))")
            return MutableStorage()
        }
        return children
    }

    public func add(_ child: ChildModel, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.add(child._entityWrapper.entity)
        entity[keyPath: keyPath] = children.immutable
    }

    public func remove(_ child: ChildModel, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.remove(child._entityWrapper.entity)
        entity[keyPath: keyPath] = children.immutable
    }
}

public extension ChildrenInterfaceProtocol where Entity: NSManagedObject, ChildModel.Entity: NSManagedObject {

    typealias Output = [ChildModel]
    typealias StoreConversionError = Never

    func publisher(for entity: Entity) -> any Publisher<Output, Never> {
        entity.publisher(for: keyPath)
            .replaceNil(with: .init())
            .map(\.array)
            .map(childModels)
    }

    private func childModels(from entities: [Any]) -> Output { entities.map(childModel) }

    private func childModel(from entity: Any) -> ChildModel {
        guard let entity = entity as? ChildModel.Entity else {
            preconditionFailure("The children are not of type \(ChildModel.Entity.self)")
        }
        return ChildModel(entity: entity)
    }

    func currentValue(on entity: Entity) -> Output {
        entity[keyPath: keyPath]?.array.map(childModel) ?? []
    }
}

extension ChildrenInterfaceProtocol where Self: FieldPublisher, Self.Output == [ChildModel], ChildModel.Entity: DatabaseEntity, Entity: NSManagedObject {

    func publisher(for entity: Entity, sortedBy sorts: [Sort<ChildModel.Entity>]) -> any Publisher<Output, Never> {
        publisher(for: entity)
            .sorted(by: sorts)
    }
}
