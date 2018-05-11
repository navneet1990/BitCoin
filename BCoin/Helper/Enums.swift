//
//  Enums.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import WatchKit
import Foundation

//MARK: API Categories enum
enum ApiType: String {
    case Today = "currentprice.json"
    case Last2Week = "historical/close.json?"
}
//MARK: Server response
enum Response{
    case failure(Error)
    case success(Data)
    case invalid
}

// MARK: Cell Identifier
enum TableCellIdenfiers: String{
    case defaultCell
    case coinRateCell
}


//MARK: Enums for keys
enum CodingKeys: String, CodingKey {
    case time
    case bpi
}
enum TimeInfoKeys: String, CodingKey {
    case updated
}

enum ConnectivityMessageIdentifiers: String {
    case currency
    case today
    case lastTwoWeeks
    case date
    case todayRate
}



