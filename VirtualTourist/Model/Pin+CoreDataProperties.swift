//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 30.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var lastPage: Int16
    @NSManaged public var photo: NSSet?

}

// MARK: Generated accessors for photo
extension Pin {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Image)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Image)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}
