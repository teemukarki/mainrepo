//
//  Treeni+CoreDataProperties.swift
//  gymnotes
//
//  Created by Teemu Kärki on 23.4.2020.
//  Copyright © 2020 teemu. All rights reserved.
//
//

import Foundation
import CoreData


extension Treeni {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Treeni> {
        return NSFetchRequest<Treeni>(entityName: "Treeni")
    }

    @NSManaged public var nimi: String
    @NSManaged public var liikkeet: NSSet?
    @NSManaged public var ohjelma: Treeniohjelma

}

// MARK: Generated accessors for liikkeet
extension Treeni {

    @objc(addLiikkeetObject:)
    @NSManaged public func addToLiikkeet(_ value: Liike)

    @objc(removeLiikkeetObject:)
    @NSManaged public func removeFromLiikkeet(_ value: Liike)

    @objc(addLiikkeet:)
    @NSManaged public func addToLiikkeet(_ values: NSSet)

    @objc(removeLiikkeet:)
    @NSManaged public func removeFromLiikkeet(_ values: NSSet)

}
