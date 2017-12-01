//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 30.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, lastPage: Int, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            print("pin init")
            self.init(entity: ent, insertInto: context)

            self.latitude = latitude
            self.longitude = longitude
            self.lastPage = Int16(lastPage)
        } else {
            fatalError("Unable to find Entity name")
        }
    }
}
