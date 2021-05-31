//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine
import CoreData

extension DatabaseModel {

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
            assertionFailure(
                "No context was provided to fetch the request. " +
                "Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'"
            )
            return Just([]).eraseToAnyPublisher()
        }

        let request = request ?? Entity.newFetchRequest()
        let sorts = [sort] + additionalSorts
        request.sortDescriptors = sorts.map(\.descriptor)
        let fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        return Publishers.fetchUpdate(for: Self.self, fetchController: fetchController)
            .eraseToAnyPublisher()
    }
}
