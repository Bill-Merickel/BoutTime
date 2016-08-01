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
    class func dictionaryFromFile(resource: String, ofType type: String) throws -> [[String : Any]] {
        guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: type) else {
            throw InventionListError.InvalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path), let castDictionary = dictionary as? [[String : Any]] else {
            throw InventionListError.ConversionError
        }
        
        return castDictionary
    }
}



class PlistUnarchiver {
    class func createListFromDictionary(dictionary: [[String: Any]]) -> [Invention] {
        var listOfInventions: [Invention] = []
        
        for invention in dictionary {
            if let event = invention["event"] as? String, let year = invention["year"] as? Int, let url = invention["url"] as? String {
                let invention = Invention(event: event, year: year, url: url)
                listOfInventions.append(invention)
            }
        }
        
        return listOfInventions
    }
}
