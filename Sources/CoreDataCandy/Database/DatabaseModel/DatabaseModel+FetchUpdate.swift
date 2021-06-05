//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine
import CoreData

extension DatabaseModel {

    private static var noContextMessage: String {
        """
        No context was provided to fetch the request.
        Consider passing it as a parameter or changing the default 'nil' value of the static property 'Fetchable.context'.
        """
    }

    /// Publish an array of the current `Model`s retrieved with a `NSFetchedResultsController`
    /// - Parameters:
    ///   - sort: First required sort to use for the fetch request
    ///   - additionalSorts: Additional sorts to be used to sort the models
    ///   - request: A custom request to use
    ///   - context: The context where to perform the request.
    ///   - note: Sends a first value upon subscription
    public static func updatePublisher(
        sortingBy sort: SortDescriptor<Entity>,
        _ additionalSorts: SortDescriptor<Entity>...,
        for request: NSFetchRequest<Entity>? = nil,
        in context: NSManagedObjectContext? = Self.context)
    -> AnyPublisher<[Self], Never> {

        guard let context = context else {
            assertionFailure(noContextMessage)
            return Just([]).eraseToAnyPublisher()
        }

        let controller = updateResultController(
            sortingBy: [sort] + additionalSorts,
            for: request ?? Entity.newFetchRequest(),
            in: context)

        return Publishers.fetchUpdate(for: Self.self, fetchController: controller)
            .eraseToAnyPublisher()
    }

    /// Return a `FetchedResultController` setup with the provided request and sorts
    /// - Parameters:
    ///   - sort: First required sort to use for the fetch request
    ///   - additionalSorts: Additional sorts to be used to sort the models
    ///   - request: A custom request to use
    ///   - context: The context where to perform the request.
    public static func updatePublisher(
        sortingBy sort: SortDescriptor<Entity>,
        _ additionalSorts: SortDescriptor<Entity>...,
        for request: NSFetchRequest<Entity>? = nil,
        in context: NSManagedObjectContext? = Self.context)
    -> NSFetchedResultsController<Entity> {

        guard let context = context else {
            preconditionFailure(noContextMessage)
        }

        return updateResultController(
            sortingBy: [sort] + additionalSorts,
            for: request ?? Entity.newFetchRequest(),
            in: context)
    }

    private static func updateResultController(
        sortingBy sorts: [SortDescriptor<Entity>],
        for request: NSFetchRequest<Entity>?,
        in context: NSManagedObjectContext)
    -> NSFetchedResultsController<Entity> {

        let request = request ?? Entity.newFetchRequest()
        request.sortDescriptors = sorts.map(\.descriptor)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
