//
//  Sarja+CoreDataProperties.swift
//  gymnotes
//
//  Created by Teemu Kärki on 29.4.2020.
//  Copyright © 2020 teemu. All rights reserved.
//
//

import Foundation
import CoreData


extension Sarja {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sarja> {
        return NSFetchRequest<Sarja>(entityName: "Sarja")
    }

    @NSManaged public var nimi: String
    @NSManaged public var pituus: String?
    @NSManaged public var sarja_erikoistekniikka: String?
    @NSManaged public var liike: Liike

}
