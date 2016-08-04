//
//  HistoricalInventionsModel.swift
//  BoutTime
//
//  Created by Bill Merickel on 7/31/16.
//  Copyright © 2016 Bill Merickel. All rights reserved.
//

import Foundation

class Invention {
    
    var event: String
    var year: Int
    var url: String
    
    init(event: String, year: Int, url: String) {
        self.event = event
        self.year = year
        self.url = url
    }
}

// Error Types

enum InventionListError: ErrorType {
    case InvalidResource
    case ConversionError
}

// Helper Classes

class PlistConverter {
    class func arrayFromFile(resource: String, ofType type: String) throws -> [[String : String]] {
        guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: type) else {
            throw InventionListError.InvalidResource
        }
        
        guard let array = NSArray(contentsOfFile: path), let castArray = array as? [[String : String]] else {
            throw InventionListError.ConversionError
        }
        
        return castArray
    }
}



class PlistUnarchiver {
    class func createListFromArray(array: [[String: String]]) -> [Invention] {
        var listOfInventions: [Invention] = []
        
        for invention in array {
            if let event = invention["event"], let year = invention["year"], let yearAsNumber = Int(year), let url = invention["url"] {
                let invention = Invention(event: event, year: yearAsNumber, url: url)
                listOfInventions.append(invention)
            }
        }
        
        return listOfInventions
    }
}

struct InventionSet {
    var invention: Invention
    var order: Int
    var position: Int
}