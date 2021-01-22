//
//  Liike+CoreDataProperties.swift
//  gymnotes
//
//  Created by Teemu Kärki on 28.4.2020.
//  Copyright © 2020 teemu. All rights reserved.
//
//

import Foundation
import CoreData


extension Liike {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Liike> {
        return NSFetchRequest<Liike>(entityName: "Liike")
    }

    @NSManaged public var erikoistekniikka: String?
    @NSManaged public var nimi: String
    @NSManaged public var paino: String?
    @NSManaged public var painohistoria: String?
    @NSManaged public var uusin_tunniste: Bool
    @NSManaged public var poisto_tunniste: Bool
    @NSManaged public var sarjat: NSSet?
    @NSManaged public var treeni: Treeni

}

// MARK: Generated accessors for sarjat
extension Liike {

    @objc(addSarjatObject:)
    @NSManaged public func addToSarjat(_ value: Sarja)

    @objc(removeSarjatObject:)
    @NSManaged public func removeFromSarjat(_ value: Sarja)

    @objc(addSarjat:)
    @NSManaged public func addToSarjat(_ values: NSSet)

    @objc(removeSarjat:)
    @NSManaged public func removeFromSarjat(_ values: NSSet)

}
