//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import XCTest
import Combine
import CoreData
import CoreDataCandy

final class DatabaseModelTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        subscriptions = []
    }

    func testAssign() throws {
        let model = StubModel()

        model.assign("Hello", to: \.property)

        XCTAssertEqual(model.current(\.property), "Hello")
    }

    func testValidate_ValidateWrongValueThrows() throws {
        let model = StubModel()

        XCTAssertThrowsError(try model.validate("Yo", for: \.property))
    }

    func testToggle() throws {
        let model = StubModel()

        model.toggle(\.flag)

        XCTAssertEqual(model.current(\.flag), true)
    }

    func testValidateAndAssignWithPublisher() throws {
        let model = StubModel()

        Just("Hello")
            .tryValidate(for: \.property, on: model)
            .assign(to: \.property, on: model) { _ in }
            .store(in: &subscriptions)
    }

    func testValidateAssignWithPublisher_ValidateWrongValueThrows() throws {
        let model = StubModel()

//        Just("Yo")
//            .tryValidate(for: \.property, on: model)
//            .sink { completion in
//                guard case .failure = completion else {
//                    XCTFail()
//                    return
//                }
//            } receiveValue: { (_) in }
//            .store(in: &subscriptions)
    }

    func testPublisherToggle() throws {
        let model = StubModel()

        Just(())
            .handleEvents(receiveCompletion: { _ in
                XCTAssertEqual(model.current(\.flag), true)
            })
            .toggle(\.flag, on: model)
            .store(in: &subscriptions)
    }

    func testPublisherToggle_SeveralTimes() throws {
        let model = StubModel()

        [(), (), (), ()].publisher
            .handleEvents(receiveCompletion: { _ in
                XCTAssertEqual(model.current(\.flag), false)
            })
            .toggle(\.flag, on: model)
            .store(in: &subscriptions)
    }

    func testAssignNil() throws {
        let model = StubModel()

        model.assign("toto", to: \.property)
        XCTAssertEqual(model.current(\.property), "toto")

        model.assign(nil, to: \.property)
        XCTAssertNil(model.current(\.property))
    }
}

extension DatabaseModelTests {

    final class StubEntity: NSManagedObject, DatabaseEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        @objc var children: NSSet?
        @objc var flag = false
        @objc var property: String? = ""
    }

    struct StubModel: DatabaseModel {

        let _entityWrapper = EntityWrapper(entity: StubEntity())

        let children = Children(\.children, as: StubModel.self)
        let property = Field(\.property, validations: .doesNotContain("Yo"))
        let flag = Field(\.flag)

        init(entity: StubEntity) {}

        init() {}
    }
}
