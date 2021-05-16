//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

extension Publishers {

    /// Tranforms a fetch controller delegate functions to a publisher
    struct FetchUpdate<Model: DatabaseModel>: Publisher {

        typealias Output = [Model]
        typealias Failure = Never

        private let subject = PassthroughSubject<[Model], Never>()
        private let fetchController: NSFetchedResultsController<Model.Entity>
        private var fetchControllerDelegate: FetchControllerDelegate?

        init(controller: NSFetchedResultsController<Model.Entity>) {
            fetchController = controller
            fetchControllerDelegate = FetchControllerDelegate(sendUpdate: sendUpdate)
            fetchController.delegate = fetchControllerDelegate
            // send a first value
            try? fetchController.performFetch()
            sendUpdate()
        }

        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            subject.receive(subscriber: subscriber)
        }

        private func sendUpdate() {
            guard let objects = fetchController.fetchedObjects else { return }
            subject.send(objects.map(Model.init))
        }
    }
}

extension Publishers.FetchUpdate {

    private final class FetchControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {

        let sendUpdate: () -> Void

        init(sendUpdate: @escaping () -> Void) {
            self.sendUpdate = sendUpdate
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            sendUpdate()
        }
    }
}

extension Publishers {

    static func fetchUpdate<Model>(for type: Model.Type, fetchController: NSFetchedResultsController<Model.Entity>)
    -> FetchUpdate<Model> {
        FetchUpdate<Model>(controller: fetchController)
    }
}
