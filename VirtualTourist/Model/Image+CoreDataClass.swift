//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 30.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {

    convenience init(url: String, title: String, pin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context) {
            print("image init")
            self.init(entity: ent, insertInto: context)
            
            self.url = url
            self.title = title
            self.pin = pin
        } else {
            fatalError("Unable to find Entity name")
        }
    }
    
}
