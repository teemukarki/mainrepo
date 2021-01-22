//
//  Treeniohjelma+CoreDataProperties.swift
//  gymnotes
//
//  Created by Teemu Kärki on 23.4.2020.
//  Copyright © 2020 teemu. All rights reserved.
//
//

import Foundation
import CoreData


extension Treeniohjelma {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Treeniohjelma> {
        return NSFetchRequest<Treeniohjelma>(entityName: "Treeniohjelma")
    }

    @NSManaged public var nimi: String
    @NSManaged public var treenit: NSSet?

}

// MARK: Generated accessors for treenit
extension Treeniohjelma {

    @objc(addTreenitObject:)
    @NSManaged public func addToTreenit(_ value: Treeni)

    @objc(removeTreenitObject:)
    @NSManaged public func removeFromTreenit(_ value: Treeni)

    @objc(addTreenit:)
    @NSManaged public func addToTreenit(_ values: NSSet)

    @objc(removeTreenit:)
    @NSManaged public func removeFromTreenit(_ values: NSSet)

}
