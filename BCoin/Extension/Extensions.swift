//
//  Extensions.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import WatchKit
import Foundation
//Mark: Today Coin Modal
extension TodayCoinModel: Decodable{
    
    // Decoding the response using JsonDecoder
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decodeTime = try values.nestedContainer(keyedBy: TimeInfoKeys.self, forKey: .time)
        
        // Decoding the Nested Response
        time = try decodeTime.decode(String.self, forKey: .updated).UTCToLocal()
        currencies = try values.decode( Currency.self, forKey: .bpi)
    }
}
//Mark: Previous Coin Modal
extension Coins : Decodable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decodeTime = try values.nestedContainer(keyedBy: TimeInfoKeys.self, forKey: .time)
        let list = try values.decode( [String:Float].self, forKey: .bpi)
        let dates = list.keys.sorted()
        
        // Decoding the Nested Response
        let time = try decodeTime.decode(String.self, forKey: .updated).UTCToLocal()
        self.init(time: time, list: list, dates: dates)
    }
}

//MARK: String Extension
extension String{
    
    func UTCToLocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d,yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM d,yyyy h:mm a"
        return dateFormatter.string(from: dt!)
    }
    
    func convertCurrencyCodeToSymbol() -> String? {
        let locale = NSLocale(localeIdentifier: self)
        if locale.displayName(forKey: .currencySymbol, value: self) == self {
            let newlocale = NSLocale(localeIdentifier: self.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: self)
        }
        return locale.displayName(forKey: .currencySymbol, value: self)
    }
}

//MARK: DateExtension
extension Date {
    func getDateBeforeDays(_ days: Int)-> Date{
        return Calendar.current.date(byAdding: .day, value: -days, to: self)!
    }
    private var dateFormatter : DateFormatter{
        let dateFormatterd = DateFormatter()
        dateFormatterd.dateFormat = "yyyy-MM-dd"
        dateFormatterd.timeZone = TimeZone.current
        
        return dateFormatterd
    }
    func changeDateToString()-> String{
        return  dateFormatter.string(from: self)
    }
    
    func lastFetchedDataIsToday(_ oldDate: String)-> Bool{
        let dateFormatterd = DateFormatter()
        dateFormatterd.timeZone = TimeZone.current
        dateFormatterd.dateFormat = "MMM d,yyyy h:mm a"
        let old = dateFormatterd.date(from: oldDate)
        if Calendar.current.compare(self, to: old!, toGranularity: .day) == .orderedSame {
            return true
        }
        return false
    }
}

