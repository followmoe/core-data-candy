//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can be fetch from the CoreData context
public protocol Fetchable {}

/// Abstract protocol on CoreData managed objec to offer fetch requests
public protocol FetchableEntity: DatabaseEntity, Fetchable {}

// MARK: - Fetchable Entity extension

extension FetchableEntity {

    static func fetch(
        for predicate: NSPredicate,
        in context: NSManagedObjectContext,
        limit: Int? = nil,
        sorts: [Sort<Self>])
    throws -> [Self] {

        let request = fetch
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        if !sorts.isEmpty {
            request.sortDescriptors = sorts.map { $0.descriptor }
        }
        let results = try context.fetch(request)
        return results
    }
}

public extension FetchableEntity {

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    /// ```
    static func fetch<V: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<V, Self, Output>,
        where predicate: ComparisonPredicate<Self, V>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(for: predicate.nsValue, in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult, RightOperand>(
        _ target: FetchTarget<LeftOperand, Self, Output>,
        where keyPath: KeyPath<Self, LeftOperand>,
        _ predOperator: OperatorPredicate<LeftOperand, RightOperand>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(for: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }

    // MARK: Optional Left Operand

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult, RightOperand>(
        _ target: FetchTarget<LeftOperand, Self, Output>,
        where keyPath: KeyPath<Self, LeftOperand?>,
        _ predOperator: OperatorPredicate<LeftOperand, RightOperand>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(for: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }
}

// MARK: - Fetchable extensnion

public extension DatabaseModel where Entity: FetchableEntity {

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    /// ```
    static func fetch<V: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<V, Self, Output>,
        where predicate: ComparisonPredicate<Entity, V>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(for: predicate.nsValue, in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult, RightOperand>(
        _ target: FetchTarget<LeftOperand, Self, Output>,
        where keyPath: KeyPath<Entity, LeftOperand>,
        _ predOperator: OperatorPredicate<LeftOperand, RightOperand>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(for: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }

    // MARK: Optional Left Operand

    /// Feth the model entity in the context
        /// - Parameters:
        ///   - target: Specify to retrieve all values, the first one, the first nth ones...
        ///   - keyPath: The property to use in the expression
        ///   - predOperator: An operator to apply to the property
        ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
        ///   - context: The context where to fetch
        /// - Throws: If the context fails to use the fetch request
        /// - Returns: The result of the fetch, depending on the given target
        ///
        /// For a given `People` model or CoreData managed object, here are some examples
        /// ```
        /// // fetch all the People whose name start with "Jo"
        /// // type: [People]
        /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
        ///
        /// // fetch all the People whose name start with "Jo", sorted by their age
        /// // type: [People]
        /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
        ///              sortedBy: .descending(\.age),
        ///              in: context)
        ///
        /// // fetch all the People older than 10 and younger than 30
        /// // type: [People]
        /// People.fetch(.all(), where: \.age, .isIn(10..<30),
        ///              in: context)
        ///
        /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
        /// // type: [People]
        /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
        ///               in: context)
        ///
        /// // fetch the first person whose surname contains "Wood"
        /// // type: People?
        /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
        ///               in: context)
        /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult, RightOperand>(
        _ target: FetchTarget<LeftOperand, Self, Output>,
        where keyPath: KeyPath<Entity, LeftOperand?>,
        _ predOperator: OperatorPredicate<LeftOperand, RightOperand>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(for: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }
}
