//
// CoreDataCandy
// Copyright © 2021-present Alexis Bridoux.
// MIT license, see LICENSE file for details

import Combine
import CoreData

extension DatabaseModel {

    /// Create a draft from the model.
    ///
    /// All the modifications performed on the draft will not be effective in the view context before `DatabaseModelDraft.save()` is called.
    /// Once called, the changes in the draft will be merged in it parent.
    public func draft() -> DatabaseModelDraft<Self> {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = entity.managedObjectContext

        guard let childEntity = try? childContext.existingObject(with: entity.objectID) as? Entity else {
            assertionFailure("The child context should find the entity in its parent context")
            let model = Self.init(entity: Entity(context: childContext))
            return DatabaseModelDraft(model: model, context: childContext)
        }

        let draftModel = Self.init(entity: childEntity)
        return DatabaseModelDraft(model: draftModel, context: childContext)
    }
}

extension DatabaseModel {

    /// Create a new draft model.
    ///
    /// All the modifications performed on the draft will not be effective in the view context before `DatabaseModelDraft.save()` is called.
    /// Once called, the draft will become a model exiting in the provided context.
    public static func createDraft(in context: NSManagedObjectContext) -> DatabaseModelDraft<Self> {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = context
        let model = Self.init(entity: Entity(context: childContext))
        return DatabaseModelDraft(model: model, context: childContext)
    }

    /// Create a new draft model.
    ///
    /// All the modifications performed on the draft will not be effective in the view context before `DatabaseModelDraft.save()` is called.
    /// Once called, the draft will become a model exiting in the view context.
    /// - note: `Fetchable.context` must not be `nil`.
    public static func createDraft() -> DatabaseModelDraft<Self> {
        guard let context = Self.context else {
            preconditionFailure("No non-nil default context was provided for 'Fetchable.context'." +
                                    "Please provide one or call 'createDraft(in:)'")
        }
        return createDraft(in: context)
    }
}

// MARK: - Draft

public final class DatabaseModelDraft<Model: DatabaseModel> {

    fileprivate let model: Model
    private var context: NSManagedObjectContext

    fileprivate init(model: Model, context: NSManagedObjectContext) {
        self.model = model
        self.context = context
    }
}

public extension DatabaseModelDraft {

    /// Try to save the draft to the real model.
    ///
    /// - Throws: If the context saving fails
    func save() throws {
        guard let context = model.entity.managedObjectContext else {
            assertionFailure("The child object (draft) has no context")
            return
        }
        guard context.hasChanges else { return }
        try context.save()
    }
}

public extension DatabaseModelDraft {

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>) -> F.Value
    where F.Entity == Model.Entity {
        model.current(keyPath)
    }

    /// The current value of the given optional field flattened to an optional
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>) -> F.Value
    where F.Entity == Model.Entity, F.FieldValue: ExpressibleByNilLiteral, F.Value: ExpressibleByNilLiteral {
        model.current(keyPath)
    }

    /// Validate the value for the given field property, throwing a relevant error if the value is invalidated
    func validate<F: FieldModifier>(_ value: F.Value, for keyPath: KeyPath<Model, F>) throws
    where F.Entity == Model.Entity {
        try model.validate(value, for: keyPath)
    }

    /// Assign the value to the given field property
    func assign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Model, F>)
    where F.Entity == Model.Entity {
        model.assign(value, to: keyPath)
    }

    /// Validate the value for the given field property then assign it, throwing a relevant error if the value is invalidated
    func validateAndAssign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Model, F>) throws
    where F.Entity == Model.Entity {
        try model.validateAndAssign(value, to: keyPath)
    }

    /// Toggle the boolean at the given key path
    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>)
    where F.Value == Bool, F.Entity == Model.Entity {
        model.toggle(keyPath)
    }

    /// Publisher for the given field
    func publisher<F: FieldPublisher>(for keyPath: KeyPath<Model, F>) -> any Publisher<F.Output, Never>
    where F.Entity == Model.Entity {
        model.publisher(for: keyPath)
    }
}
