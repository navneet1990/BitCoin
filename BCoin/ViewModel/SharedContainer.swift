//
//  SharedContainer.swift
//  BCoin
//
//  Created by Navneet Singh on 07/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import Foundation
class SharedData{
    private enum SharedDataKeys: String{
        case today = "sharedTodayData"
        case last2Weeks = "sharedLastTwoWeeksData"
    }

    private let sharedContainer = UserDefaults(suiteName: "group.Navneet.Bcoins")!
    //MARK:  TOday Container
    func resetTodayDataContainer(){
        
      sharedContainer.removeObject(forKey:SharedDataKeys.today.rawValue )
        sharedContainer.synchronize()
    }
    func addSharedDataToContainder( _ data: Data){
    
        sharedContainer.set(data, forKey: SharedDataKeys.today.rawValue)
        sharedContainer.synchronize()
    }
    
    func fetchDataFromSharedContainer()-> TodayCoinModel?{
        guard let data = sharedContainer.object(forKey: SharedDataKeys.today.rawValue)
            else{
                print("Failed")
                return nil
        }
        guard   let decode = try? JSONDecoder().decode(TodayCoinModel.self, from: data as! Data) else{
            return nil
        }
        return decode
    }
    //MARK:  Old dates Container
    
    func saveDataForOldDates(_ data: Data, _ code: CurrencyCodes){
        sharedContainer.set(data, forKey: SharedDataKeys.last2Weeks.rawValue + code.rawValue )
        sharedContainer.synchronize()
    }
    
    func fetchOldData(_ code: CurrencyCodes)-> Coins?{
        guard let data = sharedContainer.object(forKey: SharedDataKeys.last2Weeks.rawValue + code.rawValue )
            else{
                print("Failed")
                return nil
        }
        guard   let decode = try? JSONDecoder().decode(Coins.self, from: data as! Data) else{
            return nil
        }
        return decode
    }
    
}

