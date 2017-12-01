//
//  Image+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 30.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var url: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
