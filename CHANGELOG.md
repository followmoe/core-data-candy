# CoreDataCandy

All notable changes to this project will be documented in this file. `CoreDataCandy` adheres to [Semantic Versioning](http://semver.org).

---
## [1.3.0](https://github.com/ABridoux/core-data-candy/tree/1.3.0) (05/06/2021)
### Added
- `DatabaseModel.updateResultsController` to return a `NSFetchedResultsController` setup with a request and sorts

## [1.2.0](https://github.com/ABridoux/core-data-candy/tree/1.2.0) (31/05/2021)
### Added
- Draft features to modify a model without impacting the view context. Then to merge the modifications. [#2]

### Changed
- `FetchUpdate`  moved from full custom publisher to wrapper around `NSFetchedResultsController` with a `PassthroughSubject`.

## [1.1.0](https://github.com/amaris/core-data-candy/tree/1.1.0) (22/04/2021)

### Added
- Move elements in ordered children relationships 

## [1.0.0](https://github.com/amaris/core-data-candy/tree/1.0.0) (05/03/2021)

### Added
- `where(:)` filter with a single boolean

### Changed
- `Predicate` renamed to `FetchPredicate`

## [0.3.1](https://github.com/amaris/core-data-candy/tree/0.3.1) (12/02/2021)

### Fixed
- `nil` values assigned to `FieldInterface` were ignored [#32] 

## [0.3.0](https://github.com/amaris/core-data-candy/tree/0.3.0) (21/01/2021)

### Added
- Fallback value before `preconditionFailure` when converting stored value
- Store conversion error publisher
- Map current functions on `DatabaseModel` collections

### Changed
- `DatabaseFieldValue` now `Equatable`
- `PredicateRightValue` public init
- `DatabaseModel` extensions functions moved in the protocol declaration to make them customisation points.

## [0.2.2](https://github.com/amaris/core-data-candy/tree/0.2.2) (04/12/2020)

### Fixed
- `DatabaseModel.remove` useless `throws` deleted [#18]

## [0.2.1](https://github.com/amaris/core-data-candy/tree/0.2.1) (23/11/2020)

### Fixed
- `Validation.init` now public

## [0.2.0](https://github.com/amaris/core-data-candy/tree/0.2.0) (20/11/2020)

### Added
- `Codable` to store a custom type
- `CodableConvertible` to store a type with an intermediate `Codable` object. Default implementation for `NSObject`s
- Multiple sorts when subscribing to an entity relationship [#2]

### Changed
- Fetching now uses a `RequestBuilder` to specify a request
- `ComparisonPredicate` and `OperatorPredicate` have been merged into a single `Predicate` structure.
- The store conversion with an entity attribute will now exit the program if it fails rather than throwing an error
- `FetchableEntity` has been deleted to keep only `DatabaseEntity`
- Compound predicate 'and' and 'or' now use the `NSCompoundPredicate` class rather than raw values.

## [0.1.1](https://github.com/amaris/core-data-candy/tree/0.1.1) (04/11/2020)

### Fixed
- Operator predicates with second generic type

## [0.1.0](https://github.com/amaris/core-data-candy/tree/0.1.0) (04/11/2020)

Initial release.
