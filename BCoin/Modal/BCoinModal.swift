//
//  BCoinModal.swift
//  BCoin
//
//  Created by Navneet Singh on 05/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import WatchKit
import Foundation

struct Coin : Decodable{
    let rate: String
    let code : CurrencyCodes
}
struct Time: Decodable {
    let updated: String
}

struct CurrencyOld {
    var USD: Coins?
    var GBP: Coins?
    var EUR: Coins?
    
    func currencyBasedOnCode(code: CurrencyCodes)-> Coins?{
        switch code  {
        case .EUR:
            return self.EUR
            
        case .USD:
            return self.USD
            
        case .GBP:
            return self.GBP
        }
    }
}
struct Coins {
    let time : String
    let list : [String:Float]
    let dates: [String]
    
}

// Model Object for  Today Coin Rate
struct TodayCoinModel{
    
    let time: String
    let currencies: Currency
    struct Currency: Decodable {
        let USD: Coin
        let GBP: Coin
        let EUR: Coin
    }
}

// Modal for Last Two Weeks Coin Rate
struct PreviousDaysCoinModel {
    var currencies : CurrencyOld
}

// COde for CUrrency
enum CurrencyCodes: String, Decodable{
    case EUR
    case USD
    case GBP
    mutating  func setCurrencyCode(_ code: String){
        switch code {
        case "USD":
            self = .USD
        case "GBP":
            self = .GBP
        default:
            self = .EUR
        }
    }
}
