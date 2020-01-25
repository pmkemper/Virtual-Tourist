//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Philip Kemper on 24/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
// make Pin conform to the MKAnnotation protocol, so that Pins can be used directly to make Annotations
public class Pin: NSManagedObject, MKAnnotation {
    // The code below was inspired by https://stackoverflow.com/questions/46225776/annotations-not-appearing-with-core-data
    
    // coordinate is necessary to conform to the MMKAnnotation protocol
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude

        } else {
            fatalError("Unable To Find Entity Name!")
        }
    }
}
