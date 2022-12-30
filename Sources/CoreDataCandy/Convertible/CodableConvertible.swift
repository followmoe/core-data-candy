//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

/// A `Codable` object used as the codable model of a `CodableConvertible`
public protocol CodableConvertibleModel<Convertible>: Codable {
    associatedtype Convertible: CodableConvertible

    /// The  `CodableConvertible` to output
    var converted: Convertible { get }
}

/// Can be converted  to a  `CodableConvertibleModel`
public protocol CodableConvertible<CodableModel> {
    associatedtype CodableModel: CodableConvertibleModel where CodableModel.Convertible == Self

    /// The  `CodableConvertibleModel` to store
    var codableModel: CodableModel { get }
}
